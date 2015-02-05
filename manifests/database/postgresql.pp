# Class for creating the PuppetDB postgresql database. See README.md for more
# information.
class puppetdb::database::postgresql(
  $listen_addresses     = $puppetdb::params::database_host,
  $database_name        = $puppetdb::params::database_name,
  $database_username    = $puppetdb::params::database_username,
  $database_password    = $puppetdb::params::database_password,
  $manage_db            = $puppetdb::params::manage_db,
  $manage_server        = $puppetdb::params::manage_dbserver,
  $manage_package_repo  = $puppetdb::params::manage_pg_repo,
  $postgres_version     = $puppetdb::params::postgres_version,
) inherits puppetdb::params {

  if $manage_server {
    if $manage_package_repo {
      class { '::postgresql::globals':
        manage_package_repo => true,
        version             => $postgres_version,
      }
    }
    # get the pg server up and running
    class { '::postgresql::server':
      ip_mask_allow_all_users => '0.0.0.0/0',
      listen_addresses        => $listen_addresses,
    }
  }

  if $manage_db {
    # create the puppetdb database
    postgresql::server::db { $database_name:
      user     => $database_username,
      password => $database_password,
      grant    => 'all',
    }
  }
}
