require 'spec_helper'

describe 'puppetdb::database::ssl_configuration', type: :class do
  context 'on a supported platform' do
    let(:facts) { on_supported_os.take(1).first[1] }

    let(:params) do
      {
        postgresql_ssl_key_path: '/puppet/ssl/key.pem',
        postgresql_ssl_cert_path: '/puppet/ssl/cert.pem',
        postgresql_ssl_ca_cert_path: '/puppet/cert/ca.pem',
        database_name: 'puppetdb',
        database_username: 'puppetdb',
        read_database_username: 'puppetdb-read',
      }
    end

    let(:identity_map) { "#{params[:database_name]}-#{params[:database_username]}-map" }
    let(:read_identity_map) { "#{params[:database_name]}-#{params[:read_database_username]}-map" }
    let(:datadir_path) { '/var/lib/data' }

    let(:pre_condition) do
      "class { 'postgresql::server': datadir => '/var/lib/data'} "
    end

    it { is_expected.to contain_class('puppetdb::database::ssl_configuration') }
    it { is_expected.to compile.with_all_deps }

    it 'has server.key file' do
      is_expected.to contain_file('postgres private key')
        .with(
          ensure: 'present',
          owner: 'postgres',
          mode: '0600',
          path: "#{datadir_path}/server.key",
        )
        .that_requires('Package[postgresql-server]')
    end

    it 'has server.crt file' do
      is_expected.to contain_file('postgres public key')
        .with(
          ensure: 'present',
          owner: 'postgres',
          mode: '0600',
          path: "#{datadir_path}/server.crt",
        )
        .that_requires('Package[postgresql-server]')
    end

    it 'has ssl config attribute' do
      is_expected.to contain_postgresql__server__config_entry('ssl')
        .with_value('on').with_ensure('present')
        .that_requires('File[postgres private key]')
        .that_requires('File[postgres public key]')
    end

    it 'has ssl_cert_file config attribute' do
      is_expected.to contain_postgresql__server__config_entry('ssl_cert_file')
        .with_value("#{datadir_path}/server.crt").with_ensure('present')
        .that_requires('File[postgres private key]')
        .that_requires('File[postgres public key]')
    end

    it 'has ssl_key_file config attribute' do
      is_expected.to contain_postgresql__server__config_entry('ssl_key_file')
        .with_value("#{datadir_path}/server.key").with_ensure('present')
        .that_requires('File[postgres private key]')
        .that_requires('File[postgres public key]')
    end

    it 'has ssl_ca_file config attribute' do
      is_expected.to contain_postgresql__server__config_entry('ssl_ca_file')
        .with_value(params[:postgresql_ssl_ca_cert_path]).with_ensure('present')
        .that_requires('File[postgres private key]')
        .that_requires('File[postgres public key]')
    end

    context 'does not create ssl rules for puppetdb-read user by default' do
      it { is_expected.not_to contain_postgresql__server__pg_hba_rule("Allow certificate mapped connections to #{params[:database_name]} as #{params[:read_database_username]} (ipv4)") }
      it { is_expected.not_to contain_postgresql__server__pg_hba_rule("Allow certificate mapped connections to #{params[:database_name]} as #{params[:read_database_username]} (ipv6)") }
      it { is_expected.not_to contain_postgresql__server__pg_ident_rule("Map the SSL certificate of the server as a #{params[:read_database_username]} user") }
    end

    context 'configure ssl rules' do
      let(:name) { "Configure postgresql ssl rules for #{args[:database_username]}" }
      let(:args) do
        {
          database_name:     params[:database_name],
          database_username: params[:database_username],
          puppetdb_server:   params[:puppetdb_server] || facts[:networking]['fqdn'],
        }
      end

      context 'when the puppetdb_server is not set' do
        include_examples 'puppetdb::database::postgresql_ssl_rules'
      end

      context 'when the puppetdb_server is set' do
        let(:params) { super().merge({ puppetdb_server: 'puppetdb_fqdn' }) }

        include_examples 'puppetdb::database::postgresql_ssl_rules'
      end

      context 'when the create_read_user_rule is true' do
        let(:params) { super().merge({ create_read_user_rule: true }) }

        it_behaves_like 'puppetdb::database::postgresql_ssl_rules' do
          let(:args) { super().merge({ database_username: params[:read_database_username] }) }
        end
      end
    end

    context 'when the specified Postgresql version is 12 or later' do
      let(:params) do
        {
          database_name: 'puppetdb',
          database_username: 'puppetdb',
          postgres_version: '12'
        }
      end

      it 'has hba rule for puppetdb user ipv4' do
        is_expected.to contain_postgresql__server__pg_hba_rule("Allow certificate mapped connections to #{params[:database_name]} as #{params[:database_username]} (ipv4)")
          .with_type('hostssl')
          .with_database(params[:database_name])
          .with_user(params[:database_username])
          .with_address('0.0.0.0/0')
          .with_auth_method('cert')
          .with_order(0)
          .with_auth_option("map=#{identity_map} clientcert=verify-full")
      end

      it 'has hba rule for puppetdb user ipv6' do
        is_expected.to contain_postgresql__server__pg_hba_rule("Allow certificate mapped connections to #{params[:database_name]} as #{params[:database_username]} (ipv6)")
          .with_type('hostssl')
          .with_database(params[:database_name])
          .with_user(params[:database_username])
          .with_address('::0/0')
          .with_auth_method('cert')
          .with_order(0)
          .with_auth_option("map=#{identity_map} clientcert=verify-full")
      end
    end
  end
end
