require 'spec_helper'

describe 'puppetdb::server::read_database', type: :class do
  context 'on a supported platform' do
    let(:facts) do
      {
        osfamily: 'RedHat',
        operatingsystem: 'RedHat',
        puppetversion: Puppet.version,
        operatingsystemrelease: '7.0',
        fqdn: 'test.domain.local',
      }
    end

    it { is_expected.to contain_class('puppetdb::server::read_database') }

    describe 'when using default values' do
      it { is_expected.to contain_file('/etc/puppetlabs/puppetdb/conf.d/read_database.ini').with('ensure' => 'absent') }
    end

    describe 'when using minimum working values' do
      let(:params) do
        {
          'database_host' => 'puppetdb',
        }
      end

      it {
        is_expected.to contain_file('/etc/puppetlabs/puppetdb/conf.d/read_database.ini')
          .with(
            'ensure'  => 'file',
            'owner'   => 'puppetdb',
            'group'   => 'puppetdb',
            'mode'    => '0600',
          )
      }
      it {
        is_expected.to contain_ini_setting('puppetdb_read_database_username')
          .with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetlabs/puppetdb/conf.d/read_database.ini',
            'section' => 'read-database',
            'setting' => 'username',
            'value'   => 'puppetdb',
          )
      }
      it {
        is_expected.to contain_ini_setting('puppetdb_read_database_password')
          .with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetlabs/puppetdb/conf.d/read_database.ini',
            'section' => 'read-database',
            'setting' => 'password',
            'value'   => 'puppetdb',
          )
      }
      it {
        is_expected.to contain_ini_setting('puppetdb_read_classname')
          .with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetlabs/puppetdb/conf.d/read_database.ini',
            'section' => 'read-database',
            'setting' => 'classname',
            'value'   => 'org.postgresql.Driver',
          )
      }
      it {
        is_expected.to contain_ini_setting('puppetdb_read_subprotocol')
          .with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetlabs/puppetdb/conf.d/read_database.ini',
            'section' => 'read-database',
            'setting' => 'subprotocol',
            'value'   => 'postgresql',
          )
      }
      it {
        is_expected.to contain_ini_setting('puppetdb_read_subname')
          .with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetlabs/puppetdb/conf.d/read_database.ini',
            'section' => 'read-database',
            'setting' => 'subname',
            'value'   => '//puppetdb:5432/puppetdb',
          )
      }
      it {
        is_expected.to contain_ini_setting('puppetdb_read_log_slow_statements')
          .with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetlabs/puppetdb/conf.d/read_database.ini',
            'section' => 'read-database',
            'setting' => 'log-slow-statements',
            'value'   => 10,
          )
      }
      it {
        is_expected.to contain_ini_setting('puppetdb_read_conn_max_age')
          .with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetlabs/puppetdb/conf.d/read_database.ini',
            'section' => 'read-database',
            'setting' => 'conn-max-age',
            'value'   => '60',
          )
      }
      it {
        is_expected.to contain_ini_setting('puppetdb_read_conn_keep_alive')
          .with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetlabs/puppetdb/conf.d/read_database.ini',
            'section' => 'read-database',
            'setting' => 'conn-keep-alive',
            'value'   => '45',
          )
      }
      it {
        is_expected.to contain_ini_setting('puppetdb_read_conn_lifetime')
          .with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetlabs/puppetdb/conf.d/read_database.ini',
            'section' => 'read-database',
            'setting' => 'conn-lifetime',
            'value'   => '0',
          )
      }
    end
  end
end
