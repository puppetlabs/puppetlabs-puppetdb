require 'spec_helper'

describe 'puppetdb::server::global', type: :class do
  context 'on a supported platform' do
    let(:facts) do
      {
        os: {
          family: 'RedHat',
        },
        networking: {
          fqdn: 'foo.com',
        },
        service_provider: 'systemd',
      }
    end

    it { is_expected.to contain_class('puppetdb::server::global') }

    describe 'when using default values' do
      it {
        is_expected.to contain_ini_setting('puppetdb_global_vardir')
          .with(
            'ensure' => 'present',
            'path' => '/etc/puppetlabs/puppetdb/conf.d/config.ini',
            'section' => 'global',
            'setting' => 'vardir',
            'value' => '/opt/puppetlabs/server/data/puppetdb',
          )
      }
      it {
        is_expected.to contain_file('/etc/puppetlabs/puppetdb/conf.d/config.ini')
          .with(
            'ensure'  => 'file',
            'owner'   => 'root',
            'group'   => 'puppetdb',
            'mode'    => '0640',
          )
      }
    end

    describe 'when using a legacy puppetdb version' do
      let(:pre_condition) { 'class { "puppetdb::globals": version => "2.2.0", }' }

      it {
        is_expected.to contain_ini_setting('puppetdb_global_vardir')
          .with(
            'ensure' => 'present',
            'path' => '/etc/puppetdb/conf.d/config.ini',
            'section' => 'global',
            'setting' => 'vardir',
            'value' => '/var/lib/puppetdb',
          )
      }
    end
  end
end
