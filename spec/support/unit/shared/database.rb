# frozen_string_literal: true

require 'puppetlabs_spec_helper/puppetlabs_spec/puppet_internals'

shared_examples 'postgresql_psql read grant' do
  it {
    is_expected.to contain_postgresql_psql("grant select permission for #{with[:database_read_only_username]}")
      .with(
        db: with[:database_name],
        command: "GRANT SELECT
                ON ALL TABLES IN SCHEMA \"public\"
                TO \"#{with[:database_read_only_username]}\"",
        unless: "SELECT * FROM (
                  SELECT COUNT(*)
                  FROM pg_tables
                  WHERE schemaname='public'
                    AND has_table_privilege('#{with[:database_read_only_username]}', schemaname || '.' || tablename, 'SELECT')=false
                ) x
                WHERE x.count=0",
      )
  }

  it {
    is_expected.to contain_postgresql_psql("grant usage permission for #{with[:database_read_only_username]}")
      .with(
        db: with[:database_name],
        command: "GRANT USAGE
                ON ALL SEQUENCES IN SCHEMA \"public\"
                TO \"#{with[:database_read_only_username]}\"",
        unless: "SELECT * FROM (
                  SELECT COUNT(*)
                  FROM information_schema.sequences
                  WHERE sequence_schema='public'
                    AND has_sequence_privilege('#{with[:database_read_only_username]}', sequence_schema || '.' || sequence_name, 'USAGE')=false
                ) x
                WHERE x.count=0",
      )
  }

  it {
    is_expected.to contain_postgresql_psql("grant execution permission for #{with[:database_read_only_username]}")
      .with(
        db: with[:database_name],
        command: "GRANT EXECUTE
                ON ALL FUNCTIONS IN SCHEMA \"public\"
                TO \"#{with[:database_read_only_username]}\"",
        unless:  "SELECT * FROM (
                  SELECT COUNT(*)
                  FROM pg_catalog.pg_proc p
                  LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
                  WHERE n.nspname='public'
                    AND has_function_privilege('#{with[:database_read_only_username]}', p.oid, 'EXECUTE')=false
                ) x
                WHERE x.count=0",
      )
  }
end

shared_examples 'postgresql_psql default read grant' do
  it {
    is_expected.to contain_postgresql_psql("grant default select permission for #{with[:database_read_only_username]}")
      .with(
        db:      with[:database_name],
        command: "ALTER DEFAULT PRIVILEGES
                  FOR USER \"#{with[:database_username]}\"
                  IN SCHEMA \"public\"
                GRANT SELECT ON TABLES
                  TO \"#{with[:database_read_only_username]}\"",
        unless:  "SELECT
                  ns.nspname,
                  acl.defaclobjtype,
                  acl.defaclacl
                FROM pg_default_acl acl
                JOIN pg_namespace ns ON acl.defaclnamespace=ns.oid
                WHERE acl.defaclacl::text ~ '.*\\\\\"#{with[:database_read_only_username]}\\\\\"=r/#{with[:database_username]}\\\".*'
                AND nspname = 'public'",
      )
  }

  it {
    is_expected.to contain_postgresql_psql("grant default usage permission for #{with[:database_read_only_username]}")
      .with(
        db:      with[:database_name],
        command: "ALTER DEFAULT PRIVILEGES
                  FOR USER \"#{with[:database_username]}\"
                  IN SCHEMA \"public\"
                GRANT USAGE ON SEQUENCES
                  TO \"#{with[:database_read_only_username]}\"",
        unless:  "SELECT
                  ns.nspname,
                  acl.defaclobjtype,
                  acl.defaclacl
                FROM pg_default_acl acl
                JOIN pg_namespace ns ON acl.defaclnamespace=ns.oid
                WHERE acl.defaclacl::text ~ '.*\\\\\"#{with[:database_read_only_username]}\\\\\"=U/#{with[:database_username]}\\\".*'
                AND nspname = 'public'",
      )
  }

  it {
    is_expected.to contain_postgresql_psql("grant default execute permission for #{with[:database_read_only_username]}")
      .with(
        db:      with[:database_name],
        command: "ALTER DEFAULT PRIVILEGES
                  FOR USER \"#{with[:database_username]}\"
                  IN SCHEMA \"public\"
                GRANT EXECUTE ON FUNCTIONS
                  TO \"#{with[:database_read_only_username]}\"",
        unless:  "SELECT
                  ns.nspname,
                  acl.defaclobjtype,
                  acl.defaclacl
                FROM pg_default_acl acl
                JOIN pg_namespace ns ON acl.defaclnamespace=ns.oid
                WHERE acl.defaclacl::text ~ '.*\\\\\"#{with[:database_read_only_username]}\\\\\"=X/#{with[:database_username]}\\\".*'
                AND nspname = 'public'",
      )
  }
end

shared_examples 'puppetdb::database::read_only_user' do |error = false|
  let(:defaults) do
    {
      read_database_username: nil,
      database_name: nil,
      database_owner: nil,
      password_hash: false,
    }
  end
  let(:with) { defined?(args) ? defaults.merge(args) : defaults }

  if error
    it { is_expected.to raise_error(error) }
  else
    it { is_expected.to contain_puppetdb__database__read_only_user(name).with(with) }

    it {
      is_expected.to contain_postgresql__server__role(with[:read_database_username])
        .that_comes_before("Postgresql::Server::Database_grant[#{with[:database_name]} grant connection permission to #{with[:read_database_username]}]")
        .with_password_hash(with[:password_hash])
    }

    it {
      btitle = "#{with[:database_name]} grant read permission on new objects from #{with[:database_owner]} to #{with[:read_database_username]}"
      is_expected.to contain_postgresql__server__database_grant("#{with[:database_name]} grant connection permission to #{with[:read_database_username]}")
        .that_comes_before("Puppetdb::Database::Default_read_grant[#{btitle}]")
        .with(
          privilege: 'CONNECT',
          db:        with[:database_name],
          role:      with[:read_database_username],
        )
    }

    it {
      rtitle = "#{with[:database_name]} grant read permission on new objects from #{with[:database_owner]} to #{with[:read_database_username]}"
      is_expected.to contain_puppetdb__database__default_read_grant(rtitle)
        .that_comes_before("Puppetdb::Database::Read_grant[#{with[:database_name]} grant read-only permission on existing objects to #{with[:read_database_username]}]")
        .with(
          database_username:           with[:database_owner],
          database_read_only_username: with[:read_database_username],
          database_name:               with[:database_name],
          schema:                      'public',
        )
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
      is_expected.to contain_puppetdb__database__read_grant("#{with[:database_name]} grant read-only permission on existing objects to #{with[:read_database_username]}")
        .with(
          database_read_only_username: with[:read_database_username],
          database_name:               with[:database_name],
          schema:                      'public',
        )
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
  let(:defaults) { {} }
  let(:with) { defined?(args) ? defaults.merge(args) : defaults }

  if error
    it { is_expected.to raise_error(error) }
  else
    it { is_expected.to contain_puppetdb__database__read_grant(name).with(with) }

    include_examples 'postgresql_psql read grant'
  end
end

shared_examples 'puppetdb::database::default_read_grant' do |error|
  let(:defaults) { {} }
  let(:with) { defined?(args) ? defaults.merge(args) : defaults }

  if error
    it { is_expected.to raise_error(error) }
  else
    it { is_expected.to contain_puppetdb__database__default_read_grant(name).with(with) }

    include_examples 'postgresql_psql default read grant'
  end
end

shared_examples 'puppetdb::database::postgresql_ssl_rules' do |error|
  let(:defaults) { {} }
  let(:with) { defined?(args) ? defaults.merge(args) : defaults }

  if error
    it { is_expected.to raise_error(error) }
  else
    let(:identity_map_key) { "#{with[:database_name]}-#{with[:database_username]}-map" }

    it { is_expected.to contain_puppetdb__database__postgresql_ssl_rules(name).with(with) }

    it {
      is_expected.to contain_postgresql__server__pg_hba_rule("Allow certificate mapped connections to #{with[:database_name]} as #{with[:database_username]} (ipv4)")
        .with(
          type:        'hostssl',
          database:    with[:database_name],
          user:        with[:database_username],
          address:     '0.0.0.0/0',
          auth_method: 'cert',
          order:       0,
          auth_option: "map=#{identity_map_key} clientcert=1",
        )
    }

    it {
      is_expected.to contain_postgresql__server__pg_hba_rule("Allow certificate mapped connections to #{with[:database_name]} as #{with[:database_username]} (ipv6)")
        .with(
          type:        'hostssl',
          database:    with[:database_name],
          user:        with[:database_username],
          address:     '::0/0',
          auth_method: 'cert',
          order:       0,
          auth_option: "map=#{identity_map_key} clientcert=1",
        )
    }

    it {
      is_expected.to contain_postgresql__server__pg_ident_rule("Map the SSL certificate of the server as a #{with[:database_username]} user")
        .with(
          map_name:          identity_map_key,
          system_username:   with[:puppetdb_server],
          database_username: with[:database_username],
        )
    }
  end
end
