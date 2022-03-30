# ruby json-socket [![.github/workflows/ci.yml](https://github.com/foi/ruby-json-socket/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/foi/ruby-json-socket/actions/workflows/ci.yml)

JSON-socket client & server implementation. Inspired by and compatible with  [sebastianseilund/node-json-socket](https://github.com/sebastianseilund/node-json-socket/) and [crystal json-socket](https://github.com/foi/crystal-json-socket)

[Oj](https://github.com/ohler55/oj) used for encoding/parsing json.

## Installation

```
gem install json-socket
```
or in Bundler
```ruby
gem 'json-socket'
```

## Usage

server.rb

```ruby
require "json-socket"

class CustomJSONSocketServer < JSONSocket::Server

  def on_message(message, client)
    puts message
    result = message["a"] + message["b"]
    self.send_end_message({ :result => result }, client)
  end
end

server = CustomJSONSocketServer.new(host: "localhost", port: 1234, delimeter: "ц") # OR via unix socket CustomJSONSocketServer.new(unix_socket: "/tmp/s.sock", delimeter: "ц")
server.listen
```

client.rb

```ruby
require "json-socket"

to_server = JSONSocket::Client.new(host: "localhost", port: 1234, delimeter: "ц") # OR via unix socket CustomJSONSocketServer.new(unix_socket: "/tmp/s.sock", delimeter: "ц")
server.listen

10.times do |i|
  result = to_server.send({ "a" => i, "b" => i + 10 })
  p result
end
```
