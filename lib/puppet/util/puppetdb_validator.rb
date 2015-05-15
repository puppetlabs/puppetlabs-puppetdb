require 'puppet/network/http_pool'

module Puppet
  module Util
    # Validator class, for testing that PuppetDB is alive
    class PuppetdbValidator
      attr_reader :puppetdb_server
      attr_reader :puppetdb_port
      attr_reader :use_ssl
      attr_reader :test_path
      attr_reader :test_headers

      def initialize(puppetdb_server, puppetdb_port, use_ssl=true, test_path = "/pdb/meta/v1/version")
        @puppetdb_server = puppetdb_server
        @puppetdb_port   = puppetdb_port
        @use_ssl         = use_ssl
        @test_path       = test_path
        @test_headers    = { "Accept" => "application/json" }
      end

      # Utility method; attempts to make an http/https connection to the puppetdb server.
      # This is abstracted out into a method so that it can be called multiple times
      # for retry attempts.
      #
      # @return true if the connection is successful, false otherwise.
      def attempt_connection
        # All that we care about is that we are able to connect successfully via
        # http(s), so here we're simpling hitting a somewhat arbitrary low-impact URL
        # on the puppetdb server.
        conn = Puppet::Network::HttpPool.http_instance(puppetdb_server, puppetdb_port, use_ssl)

        response = conn.get(test_path, test_headers)
        unless response.kind_of?(Net::HTTPSuccess)
          Puppet.notice "Unable to connect to puppetdb server (http#{use_ssl ? "s" : ""}://#{puppetdb_server}:#{puppetdb_port}): [#{response.code}] #{response.msg}"
          return false
        end
        return true
      rescue Exception => e
        Puppet.notice "Unable to connect to puppetdb server (http#{use_ssl ? "s" : ""}://#{puppetdb_server}:#{puppetdb_port}): #{e.message}"
        return false
      end
    end
  end
end

