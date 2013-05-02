# Class: puppetdb::server::init_config
#
# This class manages puppetdb's init config file. This file
# is located at /etc/sysconfig/puppetdb for RedHat-based distributions
# and /etc/defaults/puppetdb for Debian-based distributions.
#
# Parameters:
#   ['database']        - Which database backend to use; legal values are
#                         `postgres` (default) or `embedded`.  (The `embedded`
#                         db can be used for very small installations or for
#                         testing, but is not recommended for use in production
#                         environments.  For more info, see the puppetdb docs.)

#
# Actions:
# - Manages puppetdb's init config file
#
# Requires:
# - Inifile
#
# Sample Usage:
#   class { 'puppetdb::server::database_ini':
#     database_host     => 'my.postgres.host',
#     database_port     => '5432',
#     database_username => 'puppetdb_pguser',
#     database_password => 'puppetdb_pgpasswd',
#     database_name     => 'puppetdb',
#   }
#
class puppetdb::server::init_config(
  $init_confdir             = $puppetdb::params::init_confdir,
  $init_conf_file           = $puppetdb::params::init_conf_file,
  $java_xms                 = $puppetdb::params::java_xms,
  $java_xmx                 = $puppetdb::params::java_xmx,
  $heap_dump_on_oom         = $puppetdb::params::heap_dump_on_oom,
  $java_bin                 = $puppetdb::params::java_bin,
) inherits puppetdb::params {

  if ($heap_dump_on_oom == true) {
    $heap_dump_args = '-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/var/log/puppetdb/puppetdb-oom.hprof'
  } else {
    $heap_dump_args = ''
  }

  #Set the defaults
  Ini_setting {
    path    => "${init_confdir}/${init_conf_file}",
    ensure  => present,
    section => 'global',
  }

  ini_setting {'java_args':
    setting => 'JAVA_ARGS',
    value   => "-Xms${java_xms} -Xmx${java_xmx} ${heap_dump_args}",
  }

  ini_setting {'java_bin':
    setting => 'JAVA_BIN',
    value   => $java_bin,
  }

}
