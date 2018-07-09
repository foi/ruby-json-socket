module JSONSocket
  class Server
  end

  class Client
    def initialize(host: "127.0.0.1", port: 1234, delimeter: "#", unix_socket: nil)
      @socket = if unix_socket
                  UNIXSocket.new unix_socket
                else
                  TCPSocket.new host, port
                end
      @delimeter = delimeter
    end

    def send(message)
      
    end
  end
end
