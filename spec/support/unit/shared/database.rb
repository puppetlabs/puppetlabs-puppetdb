# frozen_string_literal: true

require 'puppetlabs_spec_helper/puppetlabs_spec/puppet_internals'

# SQL fixtures for the database grant examples, kept out of the examples so they stay short.
module PuppetdbDatabaseSql
  module_function

  def grant_select(user)
    "GRANT SELECT
                ON ALL TABLES IN SCHEMA \"public\"
                TO \"#{user}\""
  end

  def grant_select_unless(user)
    "SELECT * FROM (
                  SELECT COUNT(*)
                  FROM pg_tables
                  WHERE schemaname='public'
                    AND has_table_privilege('#{user}', schemaname || '.' || tablename, 'SELECT')=false
                ) x
                WHERE x.count=0"
  end

  def grant_usage(user)
    "GRANT USAGE
                ON ALL SEQUENCES IN SCHEMA \"public\"
                TO \"#{user}\""
  end

  def grant_usage_unless(user)
    "SELECT * FROM (
                  SELECT COUNT(*)
                  FROM information_schema.sequences
                  WHERE sequence_schema='public'
                    AND has_sequence_privilege('#{user}', sequence_schema || '.' || sequence_name, 'USAGE')=false
                ) x
                WHERE x.count=0"
  end

  def grant_execute(user)
    "GRANT EXECUTE
                ON ALL FUNCTIONS IN SCHEMA \"public\"
                TO \"#{user}\""
  end

  def grant_execute_unless(user)
    "SELECT * FROM (
                  SELECT COUNT(*)
                  FROM pg_catalog.pg_proc p
                  LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
                  WHERE n.nspname='public'
                    AND has_function_privilege('#{user}', p.oid, 'EXECUTE')=false
                ) x
                WHERE x.count=0"
  end

  def default_grant(owner, user, what)
    "ALTER DEFAULT PRIVILEGES
                  FOR USER \"#{owner}\"
                  IN SCHEMA \"public\"
                GRANT #{what}
                  TO \"#{user}\""
  end

  def default_grant_unless(owner, user, acl)
    "SELECT
                  ns.nspname,
                  acl.defaclobjtype,
                  acl.defaclacl
                FROM pg_default_acl acl
                JOIN pg_namespace ns ON acl.defaclnamespace=ns.oid
                WHERE '@' || array_to_string(acl.defaclacl, '@') || '@' ~ '@(\"?)#{user}\\1=#{acl}/(\"?)#{owner}\\2@'
                AND nspname = 'public'"
  end
end

shared_examples 'postgresql_psql read grant' do
  it {
    expect(catalogue).to contain_postgresql_psql("grant select permission for #{with[:database_read_only_username]}")
      .with(db: with[:database_name], command: PuppetdbDatabaseSql.grant_select(with[:database_read_only_username]),
            unless: PuppetdbDatabaseSql.grant_select_unless(with[:database_read_only_username]))
  }

  it {
    expect(catalogue).to contain_postgresql_psql("grant usage permission for #{with[:database_read_only_username]}")
      .with(db: with[:database_name], command: PuppetdbDatabaseSql.grant_usage(with[:database_read_only_username]),
            unless: PuppetdbDatabaseSql.grant_usage_unless(with[:database_read_only_username]))
  }

  it {
    expect(catalogue).to contain_postgresql_psql("grant execution permission for #{with[:database_read_only_username]}")
      .with(db: with[:database_name], command: PuppetdbDatabaseSql.grant_execute(with[:database_read_only_username]),
            unless: PuppetdbDatabaseSql.grant_execute_unless(with[:database_read_only_username]))
  }
end

shared_examples 'postgresql_psql default read grant' do
  it {
    expect(catalogue).to contain_postgresql_psql("grant default select permission for #{with[:database_read_only_username]}")
      .with(db: with[:database_name],
            command: PuppetdbDatabaseSql.default_grant(with[:database_username], with[:database_read_only_username], 'SELECT ON TABLES'),
            unless: PuppetdbDatabaseSql.default_grant_unless(with[:database_username], with[:database_read_only_username], 'r'))
  }

  it {
    expect(catalogue).to contain_postgresql_psql("grant default usage permission for #{with[:database_read_only_username]}")
      .with(db: with[:database_name],
            command: PuppetdbDatabaseSql.default_grant(with[:database_username], with[:database_read_only_username], 'USAGE ON SEQUENCES'),
            unless: PuppetdbDatabaseSql.default_grant_unless(with[:database_username], with[:database_read_only_username], 'U'))
  }

  it {
    expect(catalogue).to contain_postgresql_psql("grant default execute permission for #{with[:database_read_only_username]}")
      .with(db: with[:database_name],
            command: PuppetdbDatabaseSql.default_grant(with[:database_username], with[:database_read_only_username], 'EXECUTE ON FUNCTIONS'),
            unless: PuppetdbDatabaseSql.default_grant_unless(with[:database_username], with[:database_read_only_username], 'X'))
  }
end

shared_examples 'puppetdb::database::read_only_user' do |error = false|
  def defaults
    {
      read_database_username: nil,
      database_name: nil,
      database_owner: nil,
      password_hash: false,
    }
  end

  def with
    defined?(args) ? defaults.merge(args) : defaults
  end

  def default_grant_title
    "#{with[:database_name]} grant read permission on new objects from #{with[:database_owner]} to #{with[:read_database_username]}"
  end

  def read_grant_title
    "#{with[:database_name]} grant read-only permission on existing objects to #{with[:read_database_username]}"
  end

  if error
    it { is_expected.to raise_error(error) }
  else
    it { is_expected.to contain_puppetdb__database__read_only_user(name).with(with) }

    it {
      expect(catalogue).to contain_postgresql__server__role(with[:read_database_username])
        .that_comes_before("Postgresql::Server::Database_grant[#{with[:database_name]} grant connection permission to #{with[:read_database_username]}]")
        .with_password_hash(with[:password_hash])
    }

    it {
      expect(catalogue).to contain_postgresql__server__database_grant("#{with[:database_name]} grant connection permission to #{with[:read_database_username]}")
        .that_comes_before("Puppetdb::Database::Default_read_grant[#{default_grant_title}]")
        .with(privilege: 'CONNECT', db: with[:database_name], role: with[:read_database_username])
    }

    it {
      expect(catalogue).to contain_puppetdb__database__default_read_grant(default_grant_title)
        .that_comes_before("Puppetdb::Database::Read_grant[#{read_grant_title}]")
        .with(database_username: with[:database_owner], database_read_only_username: with[:read_database_username],
              database_name: with[:database_name], schema: 'public')
    }

    it_behaves_like 'postgresql_psql default read grant' do
      let(:with) do
        {
          database_username: super()[:database_owner],
          database_read_only_username: super()[:read_database_username],
          database_name: super()[:database_name],
        }
      end
    end

    it {
      expect(catalogue).to contain_puppetdb__database__read_grant(read_grant_title)
        .with(database_read_only_username: with[:read_database_username], database_name: with[:database_name], schema: 'public')
    }

    it_behaves_like 'postgresql_psql read grant' do
      let(:with) do
        {
          database_read_only_username: super()[:read_database_username],
          database_name: super()[:database_name],
        }
      end
    end
  end
end

shared_examples 'puppetdb::database::read_grant' do |error|
  def with
    defined?(args) ? args : {}
  end

  if error
    it { is_expected.to raise_error(error) }
  else
    it { is_expected.to contain_puppetdb__database__read_grant(name).with(with) }

    include_examples 'postgresql_psql read grant'
  end
end

shared_examples 'puppetdb::database::default_read_grant' do |error|
  def with
    defined?(args) ? args : {}
  end

  if error
    it { is_expected.to raise_error(error) }
  else
    it { is_expected.to contain_puppetdb__database__default_read_grant(name).with(with) }

    include_examples 'postgresql_psql default read grant'
  end
end

shared_examples 'puppetdb::database::postgresql_ssl_rules' do |error|
  def with
    defined?(args) ? { postgres_version: '17' }.merge(args) : { postgres_version: '17' }
  end

  if error
    it { is_expected.to raise_error(error) }
  else
    def identity_map_key
      "#{with[:database_name]}-#{with[:database_username]}-map"
    end

    def hba_rule_attrs(address)
      {
        type: 'hostssl',
        database: with[:database_name],
        user: with[:database_username],
        address: address,
        auth_method: 'cert',
        order: 0,
        auth_option: "map=#{identity_map_key} clientcert=#{(with[:postgres_version].to_f >= 12.0) ? 'verify-full' : '1'}",
      }
    end

    it { is_expected.to contain_puppetdb__database__postgresql_ssl_rules(name).with(with) }

    it {
      expect(catalogue).to contain_postgresql__server__pg_hba_rule("Allow certificate mapped connections to #{with[:database_name]} as #{with[:database_username]} (ipv4)")
        .with(hba_rule_attrs('0.0.0.0/0'))
    }

    it {
      expect(catalogue).to contain_postgresql__server__pg_hba_rule("Allow certificate mapped connections to #{with[:database_name]} as #{with[:database_username]} (ipv6)")
        .with(hba_rule_attrs('::0/0'))
    }

    it {
      expect(catalogue).to contain_postgresql__server__pg_ident_rule("Map the SSL certificate of the server as a #{with[:database_username]} user")
        .with(map_name: identity_map_key, system_username: with[:puppetdb_server], database_username: with[:database_username])
    }
  end
end
