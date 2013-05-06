# Class: puppetdb::database::postgresql_db
#
# This class manages a postgresql database instance suitable for use
# with puppetdb.  It uses the `inkling/postgresql` puppet module for
# for creating the puppetdb database instance and user account.
#
# This class is included from the puppetdb::database::postgresql class
# but for maximum configurability, you may choose to use this class directly
# and set up the database server itself using `puppetlabs/postgresql` yourself.
#
# Parameters:
#   ['database_name']      - The name of the database instance to connect to.
#                            (defaults to `puppetdb`)
#   ['database_username']  - The name of the database user to connect as.
#                            (defaults to `puppetdb`)
#   ['database_password']  - The password for the database user.
#                            (defaults to `puppetdb`)
# Actions:
# - Creates and manages a postgres database instance for use by
#   puppetdb
#
# Requires:
# - `inkling/postgresql`
#
# Sample Usage:
#   include puppetdb::database::postgresql_db
#
class puppetdb::database::postgresql_db(
  $database_name          = $puppetdb::params::database_name,
  $database_username      = $puppetdb::params::database_username,
  $database_password      = $puppetdb::params::database_password,
) inherits puppetdb::params {

  # create the puppetdb database
  postgresql::db{ $database_name:
    user     => $database_username,
    password => $database_password,
    grant    => 'all',
    require  => Class['::postgresql::server'],
  }
}
