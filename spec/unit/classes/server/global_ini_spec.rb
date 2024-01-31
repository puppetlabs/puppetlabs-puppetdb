require 'spec_helper'

describe 'puppetdb::server::global', type: :class do
  let(:facts) { on_supported_os.take(1).first[1] }

  describe 'when using default values' do
    include_examples 'puppetdb::params'

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

    it {
      is_expected.to contain_file('/etc/puppetdb/conf.d/config.ini')
        .with(
          'ensure'  => 'file',
          'owner'   => 'root',
          'group'   => 'puppetdb',
          'mode'    => '0640',
        )
    }
  end
end
