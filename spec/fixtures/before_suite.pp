# TODO: backport to litmusimage, required for serverspec tests
package { 'iproute': ensure => installed }

# TODO: rework this hack
if $facts['os']['family'] == 'RedHat' {
  if versioncmp($facts['os']['release']['major'], '8') >= 0 {
    package { 'disable-builtin-dnf-postgresql-module':
      ensure   => 'disabled',
      name     => 'postgresql',
      provider => 'dnfmodule',
    }

    Yumrepo <| tag == 'postgresql::repo' |>
    -> Package['disable-dnf-postgresql-module']
    -> Package <| tag == 'postgresql' |>
  }
}
