# frozen_string_literal: true

RSpec::Matchers.define_negated_matcher :omit_class, :contain_class
RSpec::Matchers.define_negated_matcher :omit_firewall, :contain_firewall

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

  def firewall_rule(port, open)
    name = "#{port} accept - puppetdb"
    (open ? contain_firewall(name) : omit_firewall(name)).with(dport: port, proto: 'tcp', jump: 'accept')
  end

  it { is_expected.to contain_class('puppetdb::server::firewall').with(with) }

  it { is_expected.to((with[:open_http_port] || with[:open_ssl_port]) ? contain_class('firewall') : omit_class('firewall')) }

  it { is_expected.to firewall_rule(with[:http_port], with[:open_http_port]) }

  it { is_expected.to firewall_rule(with[:ssl_port], with[:open_ssl_port]) }
end
