# require "socket"
require "fileutils"
require "oj"
require "async/io"
require 'async/io/unix_socket'

Oj.default_options = { :mode => :strict }

module JSONSocket

  module JsonEncodeDecode

    def parse_json(string)
      return Oj.load(string)
    end

    def encode_json(object)
      return Oj.dump(object)
    end

  end

  class Server

    include JsonEncodeDecode

    def initialize(host: "127.0.0.1", port: 1234, delimeter: "#", unix_socket: nil, oj_options: nil)
      Oj.default_options = oj_options if oj_options
      @delimeter = delimeter
      @stop = false
      @server = if unix_socket
                  FileUtils.rm_f(unix_socket)
                  Async::IO::UNIXServer.wrap(unix_socket)
                else
                  Async::IO::Endpoint.parse(ARGV.pop || "tcp://#{host}:#{port}")
                end
    end

    def stop
      @stop = true
    end

    def listen
      Async do |task|
        p "task #{task.inspect}"
        begin
        @server.accept do |client|
          puts "server accept #{client.inspect}"
          client = client.set_encoding 'UTF-8'
          # https://stackoverflow.com/questions/25303943/how-to-send-a-utf-8-encoded-strings-via-tcpsocket-in-ruby/25305256
          message_length = client.gets(@delimeter).to_i
          unless message_length == 0
            on_message(parse_json(client.read(message_length)), client)
          else
            client.close
          end
        end
        rescue Exception => e
          on_error e
        end
      end
    end

    def on_error e
      STDERR.puts e.message
    end

    def on_message(message, client)
      puts "Default on_message method - please override like this: \n" \
           " \n" \
           "class CustomJSONSocketServer < JSONSocket::Server \n" \
           " \n" \
           "  def on_message(message, client)\n" \
           "    puts message \n" \
           "    self.send_end_message([1,2,3], client)\n" \
           "  end \n" \
           " \n" \
           "end \n"
      client.close
    end

    def send_end_message(message, client)
      client.set_encoding 'UTF-8'
      strigified = encode_json(message)
      client << "#{strigified.bytesize}#{@delimeter}#{strigified}"
      client.close
      p "send_end_message #{client.inspect}"
    end

  end

  class Client

    include JsonEncodeDecode

    def initialize(host: "127.0.0.1", port: 1234, delimeter: "#", unix_socket: nil, oj_options: nil)
      Oj.default_options = oj_options if oj_options
      @delimeter = delimeter
      @unix_socket = unix_socket
      @host = host
      @port = port
    end

    def handle_send_receive(socket, message)
      socket.set_encoding 'UTF-8'
      strigified = encode_json(message)
      p "send handle_send_receive #{socket.inspect}"
      socket << "#{strigified.bytesize}#{@delimeter}#{strigified}"
      p "handle_send_receive #{socket.inspect}"
      message_length = socket.gets(@delimeter).to_i
      p "handle_send_receive afetr message length #{socket.inspect}"
      return parse_json(socket.read(message_length))
    ensure
      p "client ensure #{socket.inspect}"
      socket.close
      p "client after ensure #{socket.inspect}"
    end

    def send(message)
      begin
        if @unix_socket
          UNIXSocket.open(@unix_socket) {|socket| handle_send_receive(socket, message) }
        else
          TCPSocket.open(@host, @port) {|socket| handle_send_receive(socket, message) }
        end
      rescue Exception => e
        STDERR.puts e
      end
    end

  end

end
