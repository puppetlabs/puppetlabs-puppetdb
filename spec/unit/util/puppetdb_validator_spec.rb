# frozen_string_literal: true

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

        ok_endpoint = uri.hostname == 'mypuppetdb.com' && ((uri.port == 8080 && uri.scheme == 'http') || (uri.port == 8081 && uri.scheme == 'https'))
        Puppet::HTTP::ResponseNetHTTP.new(url, nethttpok) if ok_endpoint
      end
    end
  end

  it 'returns true if connection succeeds' do
    validator = Puppet::Util::PuppetdbValidator.new('mypuppetdb.com', 8081)
    expect(validator.attempt_connection).to be true
  end

  it 'stills validate without ssl' do
    validator = Puppet::Util::PuppetdbValidator.new('mypuppetdb.com', 8080, use_ssl: false)
    expect(validator.attempt_connection).to be true
  end

  context 'when the connection fails' do
    let(:validator) { Puppet::Util::PuppetdbValidator.new(puppetdb_server, puppetdb_port) }

    context 'with a refused connection' do
      let(:puppetdb_server) { 'mypuppetdb.com' }
      let(:puppetdb_port) { 8080 }

      it do
        allow(Puppet).to receive(:notice)
        expect(validator.attempt_connection).to be false
      end

      it 'issues an appropriate notice' do
        expect(Puppet).to receive(:notice).with("Unable to connect to puppetdb server (https://#{puppetdb_server}:#{puppetdb_port}): Connection refused")
        validator.attempt_connection
      end
    end

    context 'with puppetdb not available on a reachable server' do
      let(:puppetdb_server) { 'wrongserver.com' }
      let(:puppetdb_port) { 8081 }

      it do
        allow(Puppet).to receive(:notice)
        expect(validator.attempt_connection).to be false
      end

      it 'issues an appropriate notice' do
        expect(Puppet).to receive(:notice).with("Unable to connect to puppetdb server (https://#{puppetdb_server}:#{puppetdb_port}): [404] Not found")
        validator.attempt_connection
      end
    end

    context 'with an unreachable or non-existing host:port' do
      let(:puppetdb_server) { 'non-existing.com' }
      let(:puppetdb_port) { nil }

      it do
        allow(Puppet).to receive(:notice)
        expect(validator.attempt_connection).to be false
      end

      it 'issues an appropriate notice' do
        expect(Puppet).to receive(:notice).with("Unable to connect to puppetdb server (https://#{puppetdb_server}:#{puppetdb_port}): Unknown host")
        validator.attempt_connection
      end
    end
  end
end
