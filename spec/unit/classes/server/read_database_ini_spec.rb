require 'spec_helper'

describe 'puppetdb::server::read_database', type: :class do
  let(:facts) { on_supported_os.take(1).first[1] }

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
          'owner'   => 'root',
          'group'   => 'puppetdb',
          'mode'    => '0640',
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
      is_expected.to contain_ini_setting('puppetdb_read_pgs')
        .with(
          'ensure'  => 'present',
          'path'    => '/etc/puppetlabs/puppetdb/conf.d/read_database.ini',
          'section' => 'read-database',
          'setting' => 'syntax_pgs',
          'value'   => true,
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
