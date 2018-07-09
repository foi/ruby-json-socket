Gem::Specification.new do |s|
  s.name        = 'json-socket'
  s.version     = '1.0.0'
  s.date        = '2018-07-09'
  s.summary     = "json-socket protocol implementation"
  s.description = "JSON-socket client & server implementation. Inspired by and compatible with sebastianseilund/node-json-socket"
  s.authors     = ["foi"]
  s.email       = 'foi@live.ru'
  s.files       = ["lib/json-socket.rb"]
  s.homepage    = 'https://github.com/foi/ruby-json-socket'
  s.license     = 'MIT'
  s.add_runtime_dependency "yajl-ruby", "~> 0"
  s.add_development_dependency "rspec", "~> 0"
end
