# frozen_string_literal: true

require 'spec_helper'

describe 'puppetdb::server::read_database', type: :class do
  context 'on a supported platform' do
    let(:facts) do
      {
        os: {
          family: 'RedHat',
        },
        operatingsystemrelease: '7.0',
        networking: {
          fqdn: 'test.domain.local',
        },
        service_provider: 'systemd',
      }
    end

    describe 'when passing jdbc subparams' do
      let(:params) do
        {
          read_database_host: 'localhost',
          jdbc_ssl_properties: '?ssl=true',
        }
      end

      it { is_expected.to contain_ini_setting('puppetdb_read_subname').with(section: 'read-database', setting: 'subname', value: '//localhost:5432/puppetdb?ssl=true') }
    end

    describe 'when using ssl communication' do
      let(:params) do
        {
          read_database_host: 'cheery-rime.puppetlabs.net',
          postgresql_ssl_on: true,
          ssl_key_pk8_path: '/tmp/private_key.pk8',
        }
      end
      let(:subname) do
        '//cheery-rime.puppetlabs.net:5432/puppetdb?' \
          'ssl=true&sslfactory=org.postgresql.ssl.LibPQFactory&' \
          'sslmode=verify-full&' \
          'sslrootcert=/etc/puppetlabs/puppetdb/ssl/ca.pem&' \
          'sslkey=/tmp/private_key.pk8&' \
          'sslcert=/etc/puppetlabs/puppetdb/ssl/public.pem'
      end

      it do
        expect(catalogue).to contain_ini_setting('puppetdb_read_subname')
          .with(ensure: 'present', path: '/etc/puppetlabs/puppetdb/conf.d/read_database.ini', section: 'read-database', setting: 'subname', value: subname)
      end
    end

    describe 'when using ssl communication and setting jdbc_ssl_properties as well' do
      let(:params) do
        {
          read_database_host: 'puppetdb',
          jdbc_ssl_properties: '?ssl=true',
          postgresql_ssl_on: true,
        }
      end

      it { is_expected.to compile.and_raise_error(%r{Variables 'postgresql_ssl_on' and 'jdbc_ssl_properties' can not be used at the same time!}) }
    end
  end
end
