require File.expand_path(File.dirname(__FILE__) + '/spec_helper.rb')

describe "JSONSocket::Server, JSONSocket::Client" do
  before do
    class CustomJSONSocketServer < JSONSocket::Server

      def on_message(message, client)
        puts message
        self.send_end_message(message, client)
        @stop = true
      end
    end
  end


  it "Send & receive via tcp" do
    server = CustomJSONSocketServer.new(host: "localhost", port: 1234)
    thread = Thread.new { server.listen }
    #server.listen
    to_server = JSONSocket::Client.new(host: "localhost", port: 1234)
    result = to_server.send({ "status" => "OK" })
    expect(result).to eq({ "status" => "OK" })
    thread.exit
  end

  it "Send & receive via unix_socket" do
    server = CustomJSONSocketServer.new(unix_socket: "./tmp.sock")
    thread = Thread.new { server.listen }
    #server.listen
    to_server = JSONSocket::Client.new(unix_socket: "./tmp.sock")
    result = to_server.send({ "status" => "OK" })
    expect(result).to eq({ "status" => "OK" })
    thread.exit
  end

end
