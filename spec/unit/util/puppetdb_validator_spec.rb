require 'spec_helper'
require 'puppet/util/puppetdb_validator'

describe 'Puppet::Util::PuppetdbValidator' do
  before(:each) do
    nethttpok = Net::HTTPOK.new('1.1', 200, 'OK')
    notfound = Net::HTTPNotFound.new('1.1', 404, 'Not found')

    url = '/pdb/meta/v1/version'
    if Puppet::PUPPETVERSION.to_f < 7
      conn_ok = double
      allow(conn_ok).to receive(:get).with(url, 'Accept' => 'application/json').and_return(nethttpok)
      allow(conn_ok).to receive(:read_timeout=).with(2)
      allow(conn_ok).to receive(:open_timeout=).with(2)

      conn_not_found = double
      allow(conn_not_found).to receive(:get).with('/pdb/meta/v1/version', 'Accept' => 'application/json').and_return(notfound)

      allow(Puppet::Network::HttpPool).to receive(:http_instance).and_raise('Unknown host')
      allow(Puppet::Network::HttpPool).to receive(:http_instance).with('mypuppetdb.com', 8080, true).and_raise('Connection refused')
      allow(Puppet::Network::HttpPool).to receive(:http_instance).with('mypuppetdb.com', 8080, false).and_return(conn_ok)
      allow(Puppet::Network::HttpPool).to receive(:http_instance).with('mypuppetdb.com', 8081, true).and_return(conn_ok)
      allow(Puppet::Network::HttpPool).to receive(:http_instance).with('wrongserver.com', 8081, true).and_return(conn_not_found)
    else
      http = double
      allow(Puppet::HTTP::Client).to receive(:new).and_return(http)

      allow(http).to receive(:get) do |uri, _opts|
        raise(Puppet::HTTP::HTTPError, 'Connection refused') if uri.hostname == 'mypuppetdb.com' && uri.port == 8080 && uri.scheme == 'https'
        raise Puppet::HTTP::ResponseError, Puppet::HTTP::ResponseNetHTTP.new(url, notfound) if uri.hostname == 'wrongserver.com' && uri.port == 8081 && uri.scheme == 'https'
        raise Puppet::HTTP::HTTPError, 'Unknown host' if uri.hostname == 'non-existing.com' && uri.scheme == 'https'

        if uri.hostname == 'mypuppetdb.com' && uri.port == 8080 && uri.scheme == 'http'
          Puppet::HTTP::ResponseNetHTTP.new(url, nethttpok)
        elsif uri.hostname == 'mypuppetdb.com' && uri.port == 8081 && uri.scheme == 'https'
          Puppet::HTTP::ResponseNetHTTP.new(url, nethttpok)
        end
      end
    end
  end

  it 'returns true if connection succeeds' do
    validator = Puppet::Util::PuppetdbValidator.new('mypuppetdb.com', 8081)
    expect(validator.attempt_connection).to be true
  end

  it 'stills validate without ssl' do
    validator = Puppet::Util::PuppetdbValidator.new('mypuppetdb.com', 8080, false)
    expect(validator.attempt_connection).to be true
  end

  it 'returns false and issues an appropriate notice if connection is refused' do
    puppetdb_server = 'mypuppetdb.com'
    puppetdb_port = 8080
    validator = Puppet::Util::PuppetdbValidator.new(puppetdb_server, puppetdb_port)
    expect(Puppet).to receive(:notice).with("Unable to connect to puppetdb server (https://#{puppetdb_server}:#{puppetdb_port}): Connection refused")
    expect(validator.attempt_connection).to be false
  end

  it 'returns false and issues an appropriate notice if connection succeeds but puppetdb is not available' do
    puppetdb_server = 'wrongserver.com'
    puppetdb_port = 8081
    validator = Puppet::Util::PuppetdbValidator.new(puppetdb_server, puppetdb_port)
    expect(Puppet).to receive(:notice).with("Unable to connect to puppetdb server (https://#{puppetdb_server}:#{puppetdb_port}): [404] Not found")
    expect(validator.attempt_connection).to be false
  end

  it 'returns false and issues an appropriate notice if host:port is unreachable or does not exist' do
    puppetdb_server = 'non-existing.com'
    puppetdb_port = nil
    validator = Puppet::Util::PuppetdbValidator.new(puppetdb_server, puppetdb_port)
    expect(Puppet).to receive(:notice).with("Unable to connect to puppetdb server (https://#{puppetdb_server}:#{puppetdb_port}): Unknown host")
    expect(validator.attempt_connection).to be false
  end
end
