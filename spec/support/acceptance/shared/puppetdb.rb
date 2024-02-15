# frozen_string_literal: true

shared_examples 'puppetdb' do
  let(:pp) do
    <<~PP
    if $facts['os']['family'] == 'RedHat' {
      # Work-around EL systemd in docker bug affecting forked services
      file_line { 'puppetdb-unit-remove-pidfile':
        path               => '/lib/systemd/system/puppetdb.service',
        line               => '#PIDFile=/run/puppetlabs/puppetdb/puppetdb.pid',
        match              => '^PIDFile.*',
        append_on_no_match => false,
        require            => Package['puppetdb'],
        notify             => Service['puppetdb'],
      }
    }

    # reduce pgs memory
    postgresql::server::config_entry { 'max_connections': value => '20' }
    postgresql::server::config_entry { 'shared_buffers': value => '128kB' }
    postgresql::server::config_entry { 'effective_cache_size': value => '24MB' }
    postgresql::server::config_entry { 'maintenance_work_mem': value => '1MB' }
    postgresql::server::config_entry { 'checkpoint_completion_target': value => '0.9' }
    postgresql::server::config_entry { 'wal_buffers': value => '32kB' }
    postgresql::server::config_entry { 'random_page_cost': value => '4' }
    postgresql::server::config_entry { 'effective_io_concurrency': value => '2' }
    postgresql::server::config_entry { 'work_mem': value => '204kB' }
    postgresql::server::config_entry { 'huge_pages': value => 'off' }
    postgresql::server::config_entry { 'min_wal_size': value => '80MB' }
    postgresql::server::config_entry { 'max_wal_size': value => '1GB' }

    class { 'puppetdb':
      postgres_version            => #{postgres_version},
      manage_firewall             => #{manage_firewall},
      database_max_pool_size      => '2',
      read_database_max_pool_size => '2',
      #{puppetdb_params}
    }
    -> class { 'puppetdb::master::config':
      #{puppetdb_master_config_params}
    }
    PP
  end

  it 'applies idempotently' do
    idempotent_apply(pp, debug: ENV.key?('DEBUG'))
  end
end
