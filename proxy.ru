require './lib/mdns-proxy.rb'

app = Rack::Builder.new {
  use Rack::MdnsProxy, 'hello_world'
  run Proc.new {|env| [200, {'Content-Type' => 'text/plain'}, 'Hit the proxy'] }
}

run app
