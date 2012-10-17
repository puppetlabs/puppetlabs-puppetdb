require 'puppet/network/http_pool'

# This file contains a provider for the resource type `puppetdb_conn_validator`,
# which validates the puppetdb connection by attempting an https connection.

# Utility method; attempts to make an https connection to the puppetdb server.
# This is abstracted out into a method so that it can be called multiple times
# for retry attempts.
#
# @return true if the connection is successful, false otherwise.
def attempt_connection
  begin
    host = resource[:puppetdb_server]
    port = resource[:puppetdb_port]

    # All that we care about is that we are able to connect successfully via
    # https, so here we're simpling hitting a somewhat arbitrary low-impact URL
    # on the puppetdb server.
    path = "/metrics/mbean/java.lang:type=Memory"
    headers = {"Accept" => "application/json"}
    conn = Puppet::Network::HttpPool.http_instance(host, port, true)
    response = conn.get(path, headers)
    unless response.kind_of?(Net::HTTPSuccess)
      Puppet.err "Unable to connect to puppetdb server (#{host}:#{port}): [#{response.code}] #{response.msg}"
      return false
    end
    return true
  rescue Errno::ECONNREFUSED => e
    Puppet.notice "Unable to connect to puppetdb server (#{host}:#{port}): #{e.inspect} "
    return false
  end
end

Puppet::Type.type(:puppetdb_conn_validator).provide(:puppet_https) do
  desc "A provider for the resource type `puppetdb_conn_validator`,
        which validates the puppetdb connection by attempting an https
        connection to the puppetdb server.  Uses the puppet SSL certificate
        setup from the local puppet environment to authenticate."

  def exists?
    start_time = Time.now
    timeout = resource[:timeout]

    success = attempt_connection
    unless success
      while (Time.now - start_time) < timeout
        # It can take several seconds for the puppetdb server to start up;
        # especially on the first install.  Therefore, our first connection attempt
        # may fail.  Here we have somewhat arbitrarily chosen to retry every 10
        # seconds until the configurable timeout has expired.
        Puppet.notice("Failed to connect to puppetdb; sleeping 2 seconds before retry")
        sleep 2
        success = attempt_connection
      end
    end

    unless success
      Puppet.notice("Failed to connect to puppetdb within timeout window of #{timeout} seconds; giving up.")
    end

    success
  end

  def create
    # If `#create` is called, that means that `#exists?` returned false, which
    # means that the connection could not be established... so we need to
    # cause a failure here.
    raise Puppet::Error, "Unable to connect to puppetdb server! (#{resource[:puppetdb_server]}:#{resource[:puppetdb_port]})"
  end


end
