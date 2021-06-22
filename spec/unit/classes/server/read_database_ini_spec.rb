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
          'read_database_host' => 'puppetdb',
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
            'value'   => 'puppetdb-read',
          )
      }
      it {
        is_expected.to contain_ini_setting('puppetdb_read_database_password')
          .with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetlabs/puppetdb/conf.d/read_database.ini',
            'section' => 'read-database',
            'setting' => 'password',
            'value'   => 'puppetdb-read',
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

      context 'when using ssl communication' do
        let(:params) do
          {
            read_database_host: 'puppetdb',
            postgresql_ssl_on: true,
            ssl_key_pk8_path: '/tmp/private_key.pk8',
          }
        end

        it 'configures subname correctly' do
          is_expected.to contain_ini_setting('puppetdb_read_subname')
            .with(
              ensure: 'present',
              path: '/etc/puppetlabs/puppetdb/conf.d/read_database.ini',
              section: 'read-database',
              setting: 'subname',
              value: '//puppetdb:5432/puppetdb?' \
                     'ssl=true&sslfactory=org.postgresql.ssl.LibPQFactory&' \
                     'sslmode=verify-full&' \
                     'sslrootcert=/etc/puppetlabs/puppetdb/ssl/ca.pem&' \
                     'sslkey=/tmp/private_key.pk8&' \
                     'sslcert=/etc/puppetlabs/puppetdb/ssl/public.pem',
            )
        end

        context 'when setting jdbc_ssl_properties as well' do
          let(:params) do
            {
              read_database_host: 'puppetdb',
              jdbc_ssl_properties: '?ssl=true',
              postgresql_ssl_on: true,
            }
          end

          it 'raises an error' do
            is_expected.to compile
              .and_raise_error(%r{Variables 'postgresql_ssl_on' and 'jdbc_ssl_properties' can not be used at the same time!})
          end
        end
      end
    end
  end
end
