# frozen_string_literal: true

shared_examples 'puppetdb::server::firewall' do
  let(:defaults) do
    {
      http_port: '8080',
      open_http_port: false,
      ssl_port: '8081',
      open_ssl_port: false,
    }
  end

  let(:with) { defined?(params) ? defaults.merge(params) : defaults }

  it { is_expected.to contain_class('puppetdb::server::firewall').with(with) }
  it { is_expected.to contain_class('firewall') }

  it {
    option = with[:open_http_port] ? 'to' : 'not_to'
    is_expected.method(option).call contain_firewall("#{with[:http_port]} accept - puppetdb")
      .with(
        dport: with[:http_port],
        proto: 'tcp',
        jump: 'accept',
      )
  }

  it {
    option = with[:open_ssl_port] ? 'to' : 'not_to'
    is_expected.method(option).call contain_firewall("#{with[:ssl_port]} accept - puppetdb")
      .with(
        dport: with[:ssl_port],
        proto: 'tcp',
        jump: 'accept',
      )
  }
end
