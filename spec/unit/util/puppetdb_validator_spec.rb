require 'spec_helper'
require 'puppet/util/puppetdb_validator'

describe 'Puppet::Util::PuppetdbValidator' do
  before(:each) do
    nethttpok = Net::HTTPOK.new('1.1', 200, 'OK')
    notfound = Net::HTTPNotFound.new('1.1', 404, 'Not found')

    url = '/pdb/meta/v1/version'
    if Puppet::PUPPETVERSION.to_f < 7
      conn_ok = stub
      conn_ok.stubs(:get).with(url, 'Accept' => 'application/json').returns(nethttpok)
      conn_ok.stubs(:read_timeout=).with(2)
      conn_ok.stubs(:open_timeout=).with(2)

      conn_not_found = stub
      conn_not_found.stubs(:get).with('/pdb/meta/v1/version', 'Accept' => 'application/json').returns(notfound)

      Puppet::Network::HttpPool.stubs(:http_instance).raises('Unknown host')
      Puppet::Network::HttpPool.stubs(:http_instance).with('mypuppetdb.com', 8080, true).raises('Connection refused')
      Puppet::Network::HttpPool.stubs(:http_instance).with('mypuppetdb.com', 8080, false).returns(conn_ok)
      Puppet::Network::HttpPool.stubs(:http_instance).with('mypuppetdb.com', 8081, true).returns(conn_ok)
      Puppet::Network::HttpPool.stubs(:http_instance).with('wrongserver.com', 8081, true).returns(conn_not_found)
    else
      http = stub
      Puppet::HTTP::Client.stubs(:new).returns(http)

      http.stubs(:get).with { |uri, _opts|
        uri.hostname == 'mypuppetdb.com' &&
          uri.port == 8080 &&
          uri.scheme == 'https'
      }.raises Puppet::HTTP::HTTPError, 'Connection refused'

      http.stubs(:get).with { |uri, _opts|
        uri.hostname == 'mypuppetdb.com' &&
          uri.port == 8080 &&
          uri.scheme == 'http'
      }.returns(Puppet::HTTP::ResponseNetHTTP.new(url, nethttpok))

      http.stubs(:get).with { |uri, _opts|
        uri.hostname == 'mypuppetdb.com' &&
          uri.port == 8081 &&
          uri.scheme == 'https'
      }.returns(Puppet::HTTP::ResponseNetHTTP.new(url, nethttpok))

      http.stubs(:get).with { |uri, _opts|
        uri.hostname == 'wrongserver.com' &&
          uri.port == 8081 &&
          uri.scheme == 'https'
      }.raises Puppet::HTTP::ResponseError, Puppet::HTTP::ResponseNetHTTP.new(url, notfound)

      http.stubs(:get).with { |uri, _opts|
        uri.hostname == 'non-existing.com' &&
          uri.scheme == 'https'
      }.raises Puppet::HTTP::HTTPError, 'Unknown host'
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
    Puppet.expects(:notice).with("Unable to connect to puppetdb server (https://#{puppetdb_server}:#{puppetdb_port}): Connection refused")
    expect(validator.attempt_connection).to be false
  end

  it 'returns false and issues an appropriate notice if connection succeeds but puppetdb is not available' do
    puppetdb_server = 'wrongserver.com'
    puppetdb_port = 8081
    validator = Puppet::Util::PuppetdbValidator.new(puppetdb_server, puppetdb_port)
    Puppet.expects(:notice).with("Unable to connect to puppetdb server (https://#{puppetdb_server}:#{puppetdb_port}): [404] Not found")
    expect(validator.attempt_connection).to be false
  end

  it 'returns false and issues an appropriate notice if host:port is unreachable or does not exist' do
    puppetdb_server = 'non-existing.com'
    puppetdb_port = nil
    validator = Puppet::Util::PuppetdbValidator.new(puppetdb_server, puppetdb_port)
    Puppet.expects(:notice).with("Unable to connect to puppetdb server (https://#{puppetdb_server}:#{puppetdb_port}): Unknown host")
    expect(validator.attempt_connection).to be false
  end
end
