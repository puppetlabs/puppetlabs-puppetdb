require 'spec_helper'

describe 'puppetdb::master::puppetdb_conf', type: :class do
  let :node do
    'puppetdb.example.com'
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(puppetversion: Puppet.version,
                    service_provider: 'systemd',
                    selinux: false)
      end

      let(:pre_condition) { 'class { "puppetdb": }' }

      it {
        is_expected.to contain_ini_setting('soft_write_failure')
          .with_setting('soft_write_failure')
          .with_value(false)
      }

      context 'when using default values' do
        it { is_expected.to contain_ini_setting('puppetdbserver_urls').with(value: 'https://localhost:8081/') }
      end

      context 'when using legacy_terminus' do
        let(:params) { { legacy_terminus: true } }

        it { is_expected.to contain_ini_setting('puppetdbserver').with(value: 'localhost') }
        it { is_expected.to contain_ini_setting('puppetdbport').with(value: '8081') }
      end
    end
  end
end
