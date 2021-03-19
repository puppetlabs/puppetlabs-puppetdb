require 'spec_helper'

describe 'puppetdb::server::database', type: :class do
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

    it { is_expected.to contain_class('puppetdb::server::database') }

    describe 'when using default values' do
      it {
        is_expected.to contain_file('/etc/puppetlabs/puppetdb/conf.d/database.ini')
          .with(
            'ensure'  => 'file',
            'owner'   => 'puppetdb',
            'group'   => 'puppetdb',
            'mode'    => '0600',
          )
      }
      it {
        is_expected.to contain_ini_setting('puppetdb_psdatabase_username')
          .with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetlabs/puppetdb/conf.d/database.ini',
            'section' => 'database',
            'setting' => 'username',
            'value'   => 'puppetdb',
          )
      }
      it {
        is_expected.to contain_ini_setting('puppetdb_psdatabase_password')
          .with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetlabs/puppetdb/conf.d/database.ini',
            'section' => 'database',
            'setting' => 'password',
            'value'   => 'puppetdb',
          )
      }
      it {
        is_expected.to contain_ini_setting('puppetdb_classname')
          .with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetlabs/puppetdb/conf.d/database.ini',
            'section' => 'database',
            'setting' => 'classname',
            'value'   => 'org.postgresql.Driver',
          )
      }
      it {
        is_expected.to contain_ini_setting('puppetdb_subprotocol')
          .with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetlabs/puppetdb/conf.d/database.ini',
            'section' => 'database',
            'setting' => 'subprotocol',
            'value'   => 'postgresql',
          )
      }
      it {
        is_expected.to contain_ini_setting('puppetdb_subname')
          .with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetlabs/puppetdb/conf.d/database.ini',
            'section' => 'database',
            'setting' => 'subname',
            'value'   => '//localhost:5432/puppetdb',
          )
      }
      it {
        is_expected.to contain_ini_setting('puppetdb_gc_interval')
          .with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetlabs/puppetdb/conf.d/database.ini',
            'section' => 'database',
            'setting' => 'gc-interval',
            'value'   => '60',
          )
      }
      it {
        is_expected.to contain_ini_setting('puppetdb_node_ttl')
          .with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetlabs/puppetdb/conf.d/database.ini',
            'section' => 'database',
            'setting' => 'node-ttl',
            'value'   => '7d',
          )
      }
      it {
        is_expected.to contain_ini_setting('puppetdb_node_purge_ttl')
          .with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetlabs/puppetdb/conf.d/database.ini',
            'section' => 'database',
            'setting' => 'node-purge-ttl',
            'value'   => '14d',
          )
      }
      it {
        is_expected.to contain_ini_setting('puppetdb_report_ttl')
          .with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetlabs/puppetdb/conf.d/database.ini',
            'section' => 'database',
            'setting' => 'report-ttl',
            'value'   => '14d',
          )
      }
      it {
        is_expected.to contain_ini_setting('puppetdb_log_slow_statements')
          .with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetlabs/puppetdb/conf.d/database.ini',
            'section' => 'database',
            'setting' => 'log-slow-statements',
            'value'   => 10,
          )
      }
      it {
        is_expected.to contain_ini_setting('puppetdb_conn_max_age')
          .with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetlabs/puppetdb/conf.d/database.ini',
            'section' => 'database',
            'setting' => 'conn-max-age',
            'value'   => '60',
          )
      }
      it {
        is_expected.to contain_ini_setting('puppetdb_conn_keep_alive')
          .with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetlabs/puppetdb/conf.d/database.ini',
            'section' => 'database',
            'setting' => 'conn-keep-alive',
            'value'   => '45',
          )
      }
      it {
        is_expected.to contain_ini_setting('puppetdb_conn_lifetime')
          .with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetlabs/puppetdb/conf.d/database.ini',
            'section' => 'database',
            'setting' => 'conn-lifetime',
            'value'   => '0',
          )
      }
      it { is_expected.not_to contain_ini_setting('puppetdb_database_max_pool_size') }
      it {
        is_expected.to contain_ini_setting('puppetdb_facts_blacklist')
          .with(
            'ensure'  => 'absent',
            'path'    => '/etc/puppetlabs/puppetdb/conf.d/database.ini',
            'section' => 'database',
            'setting' => 'facts-blacklist',
          )
      }
    end

    describe 'when using facts_blacklist' do
      let(:params) do
        {
          'facts_blacklist' => [
            'one_fact',
            'another_fact',
          ],
        }
      end

      it {
        is_expected.to contain_ini_setting('puppetdb_facts_blacklist')
          .with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetlabs/puppetdb/conf.d/database.ini',
            'section' => 'database',
            'setting' => 'facts-blacklist',
            'value'   => 'one_fact, another_fact',
          )
      }
    end

    describe 'when using a legacy PuppetDB version' do
      let(:pre_condition) { 'class { "puppetdb::globals": version => "2.2.0", }' }

      it {
        is_expected.to contain_ini_setting('puppetdb_psdatabase_username')
          .with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetdb/conf.d/database.ini',
            'section' => 'database',
            'setting' => 'username',
            'value'   => 'puppetdb',
          )
      }
      it {
        is_expected.to contain_ini_setting('puppetdb_psdatabase_password')
          .with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetdb/conf.d/database.ini',
            'section' => 'database',
            'setting' => 'password',
            'value'   => 'puppetdb',
          )
      }
      it {
        is_expected.to contain_ini_setting('puppetdb_classname')
          .with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetdb/conf.d/database.ini',
            'section' => 'database',
            'setting' => 'classname',
            'value'   => 'org.postgresql.Driver',
          )
      }
      it {
        is_expected.to contain_ini_setting('puppetdb_subprotocol')
          .with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetdb/conf.d/database.ini',
            'section' => 'database',
            'setting' => 'subprotocol',
            'value'   => 'postgresql',
          )
      }
      it {
        is_expected.to contain_ini_setting('puppetdb_subname')
          .with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetdb/conf.d/database.ini',
            'section' => 'database',
            'setting' => 'subname',
            'value'   => '//localhost:5432/puppetdb',
          )
      }
      it {
        is_expected.to contain_ini_setting('puppetdb_gc_interval')
          .with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetdb/conf.d/database.ini',
            'section' => 'database',
            'setting' => 'gc-interval',
            'value'   => '60',
          )
      }
      it {
        is_expected.to contain_ini_setting('puppetdb_node_ttl')
          .with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetdb/conf.d/database.ini',
            'section' => 'database',
            'setting' => 'node-ttl',
            'value'   => '7d',
          )
      }
      it {
        is_expected.to contain_ini_setting('puppetdb_node_purge_ttl')
          .with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetdb/conf.d/database.ini',
            'section' => 'database',
            'setting' => 'node-purge-ttl',
            'value'   => '14d',
          )
      }
      it {
        is_expected.to contain_ini_setting('puppetdb_report_ttl')
          .with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetdb/conf.d/database.ini',
            'section' => 'database',
            'setting' => 'report-ttl',
            'value'   => '14d',
          )
      }
      it {
        is_expected.to contain_ini_setting('puppetdb_log_slow_statements')
          .with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetdb/conf.d/database.ini',
            'section' => 'database',
            'setting' => 'log-slow-statements',
            'value'   => 10,
          )
      }
      it {
        is_expected.to contain_ini_setting('puppetdb_conn_max_age')
          .with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetdb/conf.d/database.ini',
            'section' => 'database',
            'setting' => 'conn-max-age',
            'value'   => '60',
          )
      }
      it {
        is_expected.to contain_ini_setting('puppetdb_conn_keep_alive')
          .with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetdb/conf.d/database.ini',
            'section' => 'database',
            'setting' => 'conn-keep-alive',
            'value'   => '45',
          )
      }
      it {
        is_expected.to contain_ini_setting('puppetdb_conn_lifetime')
          .with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetdb/conf.d/database.ini',
            'section' => 'database',
            'setting' => 'conn-lifetime',
            'value'   => '0',
          )
      }
      it { is_expected.not_to contain_ini_setting('puppetdb_database_max_pool_size') }
    end

    describe 'when overriding database_path for embedded' do
      let(:params) do
        {
          'database' => 'embedded',
          'database_embedded_path' => '/tmp/foo',
        }
      end

      it {
        is_expected.to contain_ini_setting('puppetdb_subname')
          .with(
            'ensure'  => 'present',
            'path'    => '/etc/puppetlabs/puppetdb/conf.d/database.ini',
            'section' => 'database',
            'setting' => 'subname',
            'value'   => 'file:/tmp/foo;hsqldb.tx=mvcc;sql.syntax_pgs=true',
          )
      }
    end

    describe 'when setting max pool size' do
      context 'on current PuppetDB' do
        describe 'to a numeric value' do
          let(:params) do
            {
              'database_max_pool_size' => 12_345,
            }
          end

          it {
            is_expected.to contain_ini_setting('puppetdb_database_max_pool_size')
              .with(
                'ensure'  => 'present',
                'path'    => '/etc/puppetlabs/puppetdb/conf.d/database.ini',
                'section' => 'database',
                'setting' => 'maximum-pool-size',
                'value'   => '12345',
              )
          }
        end

        describe 'to absent' do
          let(:params) do
            {
              'database_max_pool_size' => 'absent',
            }
          end

          it {
            is_expected.to contain_ini_setting('puppetdb_database_max_pool_size')
              .with(
                'ensure'  => 'absent',
                'path'    => '/etc/puppetlabs/puppetdb/conf.d/database.ini',
                'section' => 'database',
                'setting' => 'maximum-pool-size',
              )
          }
        end
      end

      context 'on PuppetDB 3.2' do
        let(:pre_condition) { 'class { "puppetdb::globals": version => "3.2.0", }' }

        describe 'to a numeric value' do
          let(:params) do
            {
              'database_max_pool_size' => 12_345,
            }
          end

          it {
            is_expected.to contain_ini_setting('puppetdb_database_max_pool_size')
              .with(
                'ensure'  => 'present',
                'path'    => '/etc/puppetlabs/puppetdb/conf.d/database.ini',
                'section' => 'database',
                'setting' => 'partition-conn-max',
                'value'   => '12345',
              )
          }
        end

        describe 'to absent' do
          let(:params) do
            {
              'database_max_pool_size' => 'absent',
            }
          end

          it {
            is_expected.to contain_ini_setting('puppetdb_database_max_pool_size')
              .with(
                'ensure'  => 'absent',
                'path'    => '/etc/puppetlabs/puppetdb/conf.d/database.ini',
                'section' => 'database',
                'setting' => 'partition-conn-max',
              )
          }
        end
      end

      context 'on a legacy PuppetDB version' do
        let(:pre_condition) { 'class { "puppetdb::globals": version => "2.2.0", }' }

        describe 'to a numeric value' do
          let(:params) do
            {
              'database_max_pool_size' => 12_345,
            }
          end

          it { is_expected.not_to contain_ini_setting('puppetdb_database_max_pool_size') }
        end

        describe 'to absent' do
          let(:params) do
            {
              'database_max_pool_size' => 'absent',
            }
          end

          it { is_expected.not_to contain_ini_setting('puppetdb_database_max_pool_size') }
        end
      end
    end

    describe 'when using ssl communication' do
      let(:params) do
        {
          'postgresql_ssl_on' => true,
          'ssl_key_pk8_path' => '/tmp/private_key.pk8',
        }
      end

      it 'configures subname correctly' do
        is_expected.to contain_ini_setting('puppetdb_subname')
          .with(
            ensure: 'present',
            path: '/etc/puppetlabs/puppetdb/conf.d/database.ini',
            section: 'database',
            setting: 'subname',
            value: '//localhost:5432/puppetdb?' \
                   'ssl=true&sslfactory=org.postgresql.ssl.LibPQFactory&' \
                   'sslmode=verify-full&' \
                   'sslrootcert=/etc/puppetlabs/puppetdb/ssl/ca.pem&' \
                   'sslkey=/tmp/private_key.pk8&' \
                   'sslcert=/etc/puppetlabs/puppetdb/ssl/public.pem',
          )
      end
    end
  end
end
