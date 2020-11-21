require 'puppet/network/http_pool'

# Validator class, for testing that PuppetDB is alive
class Puppet::Util::PuppetdbValidator
  attr_reader :test_uri
  attr_reader :test_headers

  def initialize(puppetdb_server, puppetdb_port, use_ssl = true, test_path = '/pdb/meta/v1/version')
    @test_uri = URI("#{use_ssl ? 'https' : 'http'}://#{puppetdb_server}:#{puppetdb_port}#{test_path}")
    @test_headers    = { 'Accept' => 'application/json' }
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
    conn = Puppet.runtime[:http]

    response = conn.get(test_uri, headers: test_headers)
    if response.is_a?(Puppet::HTTP::ResponseNetHTTP) && response.success?
      return true
    else
      Puppet.notice "Unable to connect to puppetdb server (#{test_uri}): [#{response.code}] #{response.reason}"
      return false
    end
  rescue StandardError => e
    Puppet.notice "Unable to connect to puppetdb server (#{test_uri}): #{e.message}"
    return false
  end
end
