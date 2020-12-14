require 'puppet/network/http_pool'

# Validator class, for testing that PuppetDB is alive
class Puppet::Util::PuppetdbValidator
  attr_reader :puppetdb_server
  attr_reader :puppetdb_port
  attr_reader :use_ssl
  attr_reader :test_path
  attr_reader :test_headers

  def initialize(puppetdb_server, puppetdb_port, use_ssl = true, test_path = '/pdb/meta/v1/version')
    @puppetdb_server = puppetdb_server
    @puppetdb_port   = puppetdb_port
    @use_ssl         = use_ssl
    @test_path       = test_path
    @test_headers    = { 'Accept' => 'application/json' }
  end

  def log_error(cause, code = nil)
    if code.nil?
      Puppet.notice "Unable to connect to puppetdb server (http#{use_ssl ? 's' : ''}://#{puppetdb_server}:#{puppetdb_port}): #{cause}"
    else
      Puppet.notice "Unable to connect to puppetdb server (http#{use_ssl ? 's' : ''}://#{puppetdb_server}:#{puppetdb_port}): [#{code}] #{cause}"
    end
  end

  def valid_connection_new_client?
    test_uri = URI("#{use_ssl ? 'https' : 'http'}://#{puppetdb_server}:#{puppetdb_port}#{test_path}")
    begin
      conn = Puppet.runtime[:http]
      _response = conn.get(test_uri, headers: test_headers)
      true
    rescue Puppet::HTTP::ResponseError => e
      log_error e.message, e.response.code
      false
    end
  end

  def valid_connection_old_client?
    conn = Puppet::Network::HttpPool.http_instance(puppetdb_server, puppetdb_port, use_ssl)
    response = conn.get(test_path, test_headers)
    unless response.is_a?(Net::HTTPSuccess)
      log_error(response.msg, response.code)
      return false
    end
    true
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

    if Gem::Version.new(Puppet.version) >= Gem::Version.new('7.0.0')
      valid_connection_new_client?
    else
      valid_connection_old_client?
    end
  rescue StandardError => e
    log_error(e.message)
    return false
  end
end
