# This class configures the puppet master to enable storeconfigs and to use
# puppetdb as the storeconfigs backend. See README.md for more details.
class puppetdb::master::storeconfigs (
  $puppet_conf = $puppetdb::params::puppet_conf,
  $masterless  = $puppetdb::params::masterless,
) inherits puppetdb::params {

  if $masterless {
    $puppet_conf_section = 'main'
  } else {
    $puppet_conf_section = 'master'
  }

  Ini_setting {
    section => $puppet_conf_section,
    path    => $puppet_conf,
    ensure  => present,
  }

  ini_setting { "puppet.conf/${puppet_conf_section}/storeconfigs":
    setting => 'storeconfigs',
    value   => true,
  }

  ini_setting { "puppet.conf/${puppet_conf_section}/storeconfigs_backend":
    setting => 'storeconfigs_backend',
    value   => 'puppetdb',
  }
}
