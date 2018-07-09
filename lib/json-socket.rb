require "socket"
require "yajl"

module JSONSocket
  class Server

    def initialize(host: "127.0.0.1", port: 1234, delimeter: "#", unix_socket: nil)
      @delimeter = delimeter
      @stop = false
      @server = if unix_socket
                  UNIXServer.new unix_socket
                else
                  TCPServer.new host, port
                end
    end

    def stop
      @stop = true
    end

    def listen
      loop do
        Thread.start(@server.accept) do |client|
          begin
            message_length = client.gets(@delimeter).to_i
            on_message(Yajl::Parser.parse(client.read(message_length)), client)
          rescue Exception => e
            STDERR.puts e.message
          end
        end
        break if @stop
      end
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
      strigified = Yajl::Encoder.encode(message)
      client << "#{strigified.bytesize}#{@delimeter}#{strigified}"
      client.close
    end

  end

  class Client
    def initialize(host: "127.0.0.1", port: 1234, delimeter: "#", unix_socket: nil)
      @delimeter = delimeter
      @unix_socket = unix_socket
      @host = host
      @port = port
    end

    def handle_send_receive(socket, message)
      strigified = Yajl::Encoder.encode(message)
      socket << "#{strigified.bytesize}#{@delimeter}#{strigified}"
      message_length = socket.gets(@delimeter).to_i
      return Yajl::Parser.parse(socket.read(message_length))
    end

    def send(message)
      begin
        if @unix_socket
          UNIXSocket.open(@unix_socket) {| socket| handle_send_receive(socket, message) }
        else
          TCPSocket.open(@host, @port) {| socket| handle_send_receive(socket, message) }
        end
      rescue Exception => e
        STDERR.puts e
      end
    end

  end

end
