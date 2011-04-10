require 'dnssd'
require 'rack/proxy'

module Rack
  class MdnsProxy < Rack::Proxy
    attr_reader :service_name

    def initialize app, service_name
      @@destinations ||= DestinationResolver::Mdns.new service_name
      @@destinations.refresh
    end

    def call env
      super env
    rescue Errno::ECONNREFUSED => e
      @@destinations.refresh
      call env
    end

    def rewrite_env env
      env['HTTP_HOST'] = @@destinations.next
      env
    end
  end

  module DestinationResolver
    class Mdns
      attr_reader :hosts

      def initialize service_name
        @service_name = service_name
        refresh  
      end

      def refresh
        @hosts = Set.new
        DNSSD.browse("_#{@service_name}._tcp") do |record|
          DNSSD.resolve!(record) do |resolve_record|
            hosts << "#{resolve_record.target}:#{resolve_record.port}"
            break
          end
        end
      end

      def next
        sleep_until { hosts.size > 0 }
        hosts.to_a[rand(hosts.size)]
      end
      
      def sleep_until &block
        loop { break if yield; sleep(1) }
      end    
    end
  end
end
