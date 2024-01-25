# some provision environments (docker) may not setup or isolate domains
# this ensures the instance FQDN is always resolved locally
host { 'primary':
  name         => $facts['networking']['fqdn'],
  ip           => $facts['networking']['ip'],
  host_aliases => [
    $facts['networking']['hostname'],
  ],
}

# TODO: backport to litmusimage, required for serverspec tests
package { 'iproute': ensure => installed }

# TODO: rework this hack
if $facts['os']['family'] == 'RedHat' and versioncmp($facts['os']['release']['major'], '8') >= 0 {
  package { 'disable-builtin-dnf-postgresql-module':
    ensure   => 'disabled',
    name     => 'postgresql',
    provider => 'dnfmodule',
  }

  Yumrepo <| tag == 'postgresql::repo' |>
  -> Package['disable-dnf-postgresql-module']
  -> Package <| tag == 'postgresql' |>
}
