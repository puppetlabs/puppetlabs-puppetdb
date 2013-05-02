# Class: puppetdb::server::init_config
#
# This class manages puppetdb's init config file. This file
# is located at /etc/sysconfig/puppetdb for RedHat-based distributions
# and /etc/defaults/puppetdb for Debian-based distributions.
#
# Parameters:
#   ['init_confdir']      - The directory where the init configuration file is.
#                           For Redhat-based distributions this is usually
#                           `/etc/sysconfig/` and for Debian-based distributions
#                           it is usually `/etc/defaults`.
#   ['init_conf_file']    - The file where the init configuration is stored.
#                           For open-source puppet this is usually `puppetdb` while
#                           enterprise is `pe-puppetdb`.
#   ['java_xms']          - The Java XMS memory setting; defaults to `192m`.
#   ['java_xmx']          - The Java XMX memory setting; defaults to `192m`.
#   ['heap_dump_on_oom']  - If true, perform heap dump on out of memory. Heap dump
#                           location is '/var/log/puppetdb/puppetdb-oom.hprof'.
#   ['java_bin']          - Location of your Java binary (version 6 or higher);
#                           defaults to '/usr/bin/java'
#   ['confdir']           - The puppetdb configuration directory; defaults to
#                           `/etc/puppetdb/conf.d`.
#   ['installdir']        - The puppetdb install directory; defaults to
#                           `/usr/share/puppetdb` for open-source installs
#                           and `/opt/puppet/share/puppetdb` for enterprise.
#
# Actions:
# - Manages puppetdb's init config file
#
# Sample Usage:
#   class { 'puppetdb::server::init_config':
#     java_xms            => '512m',
#     java_xmx            => '512m',
#   }
#
class puppetdb::server::init_config(
  $init_confdir             = $puppetdb::params::init_confdir,
  $init_conf_file           = $puppetdb::params::init_conf_file,
  $java_xms                 = $puppetdb::params::java_xms,
  $java_xmx                 = $puppetdb::params::java_xmx,
  $heap_dump_on_oom         = $puppetdb::params::heap_dump_on_oom,
  $java_bin                 = $puppetdb::params::java_bin,
  $confdir                  = $puppetdb::params::confdir,
  $installdir               = $puppetdb::params::installdir,
) inherits puppetdb::params {

  if ($heap_dump_on_oom == true) {
    $heap_dump_args = '-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/var/log/puppetdb/puppetdb-oom.hprof'
  } else {
    $heap_dump_args = ''
  }

  file { "${init_confdir}/${init_conf_file}":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("${module_name}/init_config.erb"),
    notify  => Service['puppetdb'],
  }
}
