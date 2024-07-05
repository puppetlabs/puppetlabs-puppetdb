# @summary manage the installation of the report processor on the primary
#
# @api private
class puppetdb::master::report_processor (
  Stdlib::Absolutepath $puppet_conf = $puppetdb::params::puppet_conf,
  Boolean              $masterless  = $puppetdb::params::masterless,
  Boolean              $enable      = false
) inherits puppetdb::params {
  if $masterless {
    $puppet_conf_section = 'main'
  } else {
    $puppet_conf_section = 'master'
  }

  $puppetdb_ensure = $enable ? {
    true    => present,
    default => absent,
  }

  ini_subsetting { 'puppet.conf/reports/puppetdb':
    ensure               => $puppetdb_ensure,
    path                 => $puppet_conf,
    section              => $puppet_conf_section,
    setting              => 'reports',
    subsetting           => 'puppetdb',
    subsetting_separator => ',',
  }
}
