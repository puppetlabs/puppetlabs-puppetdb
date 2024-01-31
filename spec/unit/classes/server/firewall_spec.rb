require 'spec_helper'

describe 'puppetdb::server::firewall', type: :class do
  let(:facts) { on_supported_os.take(1).first[1] }

  context 'defaults' do
    include_examples 'puppetdb::server::firewall'
  end

  context 'custom ports and open firewall' do
    let(:params) do
      {
        http_port: '9000',
        open_http_port: true,
        ssl_port: '9001',
        open_ssl_port: true,
      }
    end

    include_examples 'puppetdb::server::firewall'
  end
end
