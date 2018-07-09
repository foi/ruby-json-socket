require File.expand_path(File.dirname(__FILE__) + '/spec_helper.rb')

describe "JSONSocket::Server, JSONSocket::Client" do
  before do
    class CustomJSONSocketServer < JSONSocket::Server

      def on_message(message, client)
        self.send_end_message(message, client)
        @stop = true
      end
    end

    class CalcJSONSocketServer < JSONSocket::Server

      def on_message(message, client)
        self.send_end_message({ :result => message["a"] + message["b"]}, client)
      end
    end
  end

  it "Send & receive via tcp" do
    server = CustomJSONSocketServer.new(host: "localhost", port: 1234)
    thread = Thread.new { server.listen }
    to_server = JSONSocket::Client.new(host: "localhost", port: 1234)
    result = to_server.send({ "status" => "OK" })
    expect(result).to eq({ "status" => "OK" })
    thread.exit
  end

  it "Send & receive via unix_socket" do
    server = CustomJSONSocketServer.new(unix_socket: "./tmp.sock")
    thread = Thread.new { server.listen }
    to_server = JSONSocket::Client.new(unix_socket: "./tmp.sock")
    result = to_server.send({ "вы" => "OK" })
    expect(result).to eq({ "вы" => "OK" })
    thread.exit
  end

  it "Send & receive via tcp with custom ascii delimeter" do
    server = CustomJSONSocketServer.new(host: "localhost", port: 12345, delimeter: "µ")
    thread = Thread.new { server.listen }
    to_server = JSONSocket::Client.new(host: "localhost", port: 12345, delimeter: "µ")
    result = to_server.send({ "пппs" => "OK" })
    expect(result).to eq({ "пппs" => "OK" })
    thread.exit
  end

  it "Send & receive via unix_socket with custom ascii delimeter" do
    server = CustomJSONSocketServer.new(unix_socket: "./tmp.sock", delimeter: "µ")
    thread = Thread.new { server.listen }
    to_server = JSONSocket::Client.new(unix_socket: "./tmp.sock", delimeter: "µ")
    result = to_server.send({ "status" => "OK" })
    expect(result).to eq({ "status" => "OK" })
    thread.exit
  end

  it "Send & receive via tcp with custom unicode delimeter" do
    server = CustomJSONSocketServer.new(host: "localhost", port: 12346, delimeter: "µ")
    thread = Thread.new { server.listen }
    to_server = JSONSocket::Client.new(host: "localhost", port: 12346, delimeter: "µ")
    result = to_server.send({ "пппs" => "OK" })
    expect(result).to eq({ "пппs" => "OK" })
    thread.exit
  end

  it "Send & receive via unix_socket with custom unicode delimeter" do
    server = CustomJSONSocketServer.new(unix_socket: "./tmp.sock", delimeter: "й")
    thread = Thread.new { server.listen }
    to_server = JSONSocket::Client.new(unix_socket: "./tmp.sock", delimeter: "й")
    result = to_server.send({ "status" => "OK" })
    expect(result).to eq({ "status" => "OK" })
    thread.exit
  end

  it "multiple queries to server via tcp socket" do
    calc_server = CalcJSONSocketServer.new(unix_socket: "./tmp.sock", delimeter: "|")
    thread = Thread.new { calc_server.listen }
    to_server = JSONSocket::Client.new(unix_socket: "./tmp.sock", delimeter: "|")
    sum = 0
    5.times do
      result = to_server.send({ a: 1, b: 2 })
      sum = sum + result["result"]
    end
    expect(sum).to eq(15)
    thread.exit
  end

end
