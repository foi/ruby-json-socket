require "./lib/json-socket.rb"
require "socket"

def is_port_open?(host, port, timeout = 0.5, sleep_period = 0.5)
  begin
    Timeout::timeout(timeout) do
      begin
        s = TCPSocket.new(host, port)
        s.close
        return true
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
        sleep(sleep_period)
        retry
      end
    end
  rescue Timeout::Error
    return false
  end
end

def does_path_exist?(path)
  begin
    File.exist?(path)
  rescue e
    sleep 0.5
    retry
  end
end
