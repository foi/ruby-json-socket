Gem::Specification.new do |s|
  s.name        = 'json-socket'
  s.version     = '1.0.4'
  s.date        = '2023-02-04'
  s.summary     = "json-socket protocol implementation"
  s.description = "JSON-socket client & server implementation. Inspired by and compatible with sebastianseilund/node-json-socket"
  s.authors     = ["foi"]
  s.email       = 'foi@live.ru'
  s.files       = ["lib/json-socket.rb"]
  s.homepage    = 'https://github.com/foi/ruby-json-socket'
  s.license     = 'MIT'
  s.add_runtime_dependency "oj"
  s.add_development_dependency "rspec"
end
