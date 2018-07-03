require 'spec_helper'

describe 'puppetdb::server::read_database', type: :class do
  context 'on a supported platform' do
    let(:facts) do
      {
        osfamily: 'RedHat',
        operatingsystem: 'RedHat',
        operatingsystemrelease: '7.0',
        fqdn: 'test.domain.local',
      }
    end

    describe 'when setting database_ssl flag' do
      let(:params) do
        {
          # this sets read_database_host
          'database_host' => 'localhost',
          'database_ssl' => true,
        }
      end

      it {
        is_expected.to contain_ini_setting('puppetdb_read_subname')
          .with(
            'section' => 'read-database',
            'setting' => 'subname',
            'value'   => '//localhost:5432/puppetdb?ssl=true',
          )
      }
    end

    describe 'when passing jdbc subparams' do
      let(:params) do
        {
          'database_host' => 'localhost',
          'jdbc_ssl_properties' => '?ssl=true',
        }
      end

      it {
        is_expected.to contain_ini_setting('puppetdb_read_subname')
          .with(
            'section' => 'read-database',
            'setting' => 'subname',
            'value'   => '//localhost:5432/puppetdb?ssl=true',
          )
      }
    end

    describe 'when passing both database_ssl and jdbc subparams' do
      let(:params) do
        {
          'database_host' => 'localhost',
          'database_ssl' => true,
          'jdbc_ssl_properties' => '?ssl=true&sslmode=verify-full',
        }
      end

      it {
        is_expected.to contain_ini_setting('puppetdb_read_subname')
          .with(
            'section' => 'read-database',
            'setting' => 'subname',
            'value'   => '//localhost:5432/puppetdb?ssl=true&sslmode=verify-full',
          )
      }
    end
  end
end
