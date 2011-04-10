#!/usr/bin/env ruby
require 'thin'
require 'dnssd'

port = ARGV[0].to_i

raise "specify a port" unless port

puts "REgistering on port #{port}"
DNSSD.register!("Hello World", "_hello_world._tcp", nil, port) do
  Thin::Server.start('0.0.0.0', port.to_s) { run Proc.new {|env| [200, {'Content-Type' => 'text/plain'}, "Hello World #{env['SERVER_PORT']}"]} }
end

