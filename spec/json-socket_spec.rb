require File.expand_path(File.dirname(__FILE__) + '/spec_helper.rb')

describe "JSONSocket::Server, JSONSocket::Client" do
  before do
    class CustomJSONSocketServer < JSONSocket::Server

      def on_message(message, client)
        self.send_end_message(message, client)
      end
    end

    class CalcJSONSocketServer < JSONSocket::Server

      def on_message(message, client)
        self.send_end_message({ :result => message["a"] + message["b"]}, client)
      end
    end
  end

  it "Send & receive via tcp" do
    server = CustomJSONSocketServer.new(host: "127.0.0.1", port: 1234)
    thread = Thread.new { server.listen }
    if is_port_open?("127.0.0.1", 1234, 1, 1)
      to_server = JSONSocket::Client.new(host: "127.0.0.1", port: 1234)
      result = to_server.send({ "status" => "OK" })
      expect(result).to eq({ "status" => "OK" })
      thread.exit
    end
  end

  it "Send & receive via unix_socket" do
    server = CustomJSONSocketServer.new(unix_socket: "./tmp.sock")
    thread = Thread.new { server.listen }
    if does_path_exist?("./tmp.sock")
      to_server = JSONSocket::Client.new(unix_socket: "./tmp.sock")
      result = to_server.send({ "вы" => "OK" })
      expect(result).to eq({ "вы" => "OK" })
      thread.exit
    end
  end

  it "Send & receive via tcp with custom ascii delimeter" do
    server = CustomJSONSocketServer.new(host: "127.0.0.1", port: 12345, delimeter: "µ")
    thread = Thread.new { server.listen }
    if is_port_open?("127.0.0.1", 12345)
      to_server = JSONSocket::Client.new(host: "127.0.0.1", port: 12345, delimeter: "µ")
      result = to_server.send({ "пппs" => "OK" })
      expect(result).to eq({ "пппs" => "OK" })
      thread.exit
    end
  end

  it "Send & receive via unix_socket with custom ascii delimeter" do
    server = CustomJSONSocketServer.new(unix_socket: "./tmp.sock", delimeter: "µ")
    thread = Thread.new { server.listen }
    if does_path_exist?("./tmp.sock")
      to_server = JSONSocket::Client.new(unix_socket: "./tmp.sock", delimeter: "µ")
      result = to_server.send({ "status" => "OK" })
      expect(result).to eq({ "status" => "OK" })
      thread.exit
    end
  end

  it "Send & receive via tcp with custom unicode delimeter" do
    server = CustomJSONSocketServer.new(host: "127.0.0.1", port: 12346, delimeter: "µ")
    thread = Thread.new { server.listen }
    if is_port_open?("127.0.0.1", 12346)
      to_server = JSONSocket::Client.new(host: "127.0.0.1", port: 12346, delimeter: "µ")
      result = to_server.send({ "пппs" => "OK" })
      expect(result).to eq({ "пппs" => "OK" })
      thread.exit
    end
  end

  it "Send & receive via unix_socket with custom unicode delimeter" do
    server = CustomJSONSocketServer.new(unix_socket: "./tmp.sock", delimeter: "й")
    thread = Thread.new { server.listen }
    if does_path_exist?("./tmp.sock")
      to_server = JSONSocket::Client.new(unix_socket: "./tmp.sock", delimeter: "й")
      result = to_server.send({ "status" => "OK" })
      expect(result).to eq({ "status" => "OK" })
      thread.exit
    end
  end

  it "multiple queries to server via tcp socket" do
    calc_server = CalcJSONSocketServer.new(host: "127.0.0.1", port: 1343, delimeter: "|")
    thread = Thread.new { calc_server.listen }
    if is_port_open?("127.0.0.1", 1343)
      to_server = JSONSocket::Client.new(host: "127.0.0.1", port: 1343, delimeter: "|")
      sum = 0
      5.times do |i|
        result = to_server.send({ a: 1, b: 2 })
        sum = sum + result["result"]
      end
      expect(sum).to eq(15)
      thread.exit
    end
  end

  it "multiple queries to server via unix socket" do
    calc_server = CalcJSONSocketServer.new(unix_socket: "./tmp.sock", delimeter: "|")
    thread = Thread.new { calc_server.listen }
    if does_path_exist?("./tmp.sock")
      to_server = JSONSocket::Client.new(unix_socket: "./tmp.sock", delimeter: "|")
      sum = 0
      5.times do |i|
        result = to_server.send({ a: 1, b: 2 })
        sum = sum + result["result"]
      end
      expect(sum).to eq(15)
      thread.exit
    end
  end

end
