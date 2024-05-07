# frozen_string_literal: true

require 'spec_helper'

describe 'puppetdb::database::postgresql', type: :class do
  let(:facts) { on_supported_os.take(1).first[1] }

  context 'on a supported platform' do
    it { is_expected.to contain_class('puppetdb::database::postgresql') }

    it { is_expected.to contain_class('postgresql::server::contrib') }

    it {
      is_expected.to contain_postgresql__server__extension('pg_trgm')
        .that_requires('Postgresql::Server::Db[puppetdb]')
        .with_database('puppetdb')
    }

    context 'when ssl communication is used' do
      let(:params) do
        {
          postgresql_ssl_on: true,
        }
      end

      it { is_expected.to contain_class('puppetdb::database::ssl_configuration') }

      context 'when params disable create_read_user_rule' do
        let(:params) { super().merge({ manage_database: false }) }

        it { is_expected.not_to contain_puppetdb__database__postgresql_ssl_rules('Configure postgresql ssl rules for puppetdb-read') }
      end
    end

    context 'when ssl communication is not used' do
      let(:params) do
        {
          postgresql_ssl_on: false,
        }
      end

      it { is_expected.not_to contain_class('puppetdb::database::ssl_configuration') }
    end

    context 'manage database with defaults' do
      let(:params) do
        {
          manage_database: true,
          database_name: 'puppetdb',
          database_username: 'puppetdb',
          database_password: 'puppetdb',
          read_database_username: 'puppetdb-read',
          read_database_password: 'puppetdb-read',
          database_port: '5432',
        }
      end

      it {
        is_expected.to contain_postgresql__server__db(params[:database_name])
          .with(
            user:     params[:database_username],
            password: params[:database_password],
            grant:    'all',
            port:     params[:database_port].to_i,
            encoding: 'UTF8',
            locale:   'en_US.UTF-8',
          )
      }

      it {
        is_expected.to contain_postgresql_psql('revoke all access on public schema')
          .that_requires("Postgresql::Server::Db[#{params[:database_name]}]")
          .with(
            db:      params[:database_name],
            port:    params[:database_port].to_i,
            command: 'REVOKE CREATE ON SCHEMA public FROM public',
            unless:  "SELECT * FROM
                  (SELECT has_schema_privilege('public', 'public', 'create') can_create) privs
                WHERE privs.can_create=false",
          )
      }

      it {
        is_expected.to contain_postgresql_psql("grant all permissions to #{params[:database_username]}")
          .that_requires('Postgresql_psql[revoke all access on public schema]')
          .that_comes_before("Puppetdb::Database::Read_only_user[#{params[:read_database_username]}]")
          .with(
            db:      params[:database_name],
            port:    params[:database_port].to_i,
            command: "GRANT CREATE ON SCHEMA public TO \"#{params[:database_username]}\"",
            unless:  "SELECT * FROM
                  (SELECT has_schema_privilege('#{params[:database_username]}', 'public', 'create') can_create) privs
                WHERE privs.can_create=true",
          )
      }

      it_behaves_like 'puppetdb::database::read_only_user' do
        let(:name) { 'puppetdb-read' }
        let(:args) do
          {
            read_database_username: params[:read_database_username],
            database_name:          params[:database_name],
            password_hash:          %r{^(md5|SCRAM)}, # TODO: mock properly
            database_owner:         params[:database_username],
            database_port:          params[:database_port].to_i,
          }
        end
      end

      it {
        is_expected.to contain_postgresql_psql("grant #{params[:read_database_username]} role to #{params[:database_username]}")
          .that_requires("Puppetdb::Database::Read_only_user[#{params[:read_database_username]}]")
          .with(
            db:      params[:database_name],
            port:    params[:database_port].to_i,
            command: "GRANT \"#{params[:read_database_username]}\" TO \"#{params[:database_username]}\"",
            unless:  "SELECT oid, rolname FROM pg_roles WHERE
                   pg_has_role( '#{params[:database_username]}', oid, 'member') and rolname = '#{params[:read_database_username]}'",
          )
      }
    end
  end
end
