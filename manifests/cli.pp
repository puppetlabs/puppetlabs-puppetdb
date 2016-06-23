class puppetdb::cli (
  $confdir          = '/etc/puppetlabs/client-tools',
  $server_urls      = ["http://${puppetdb::params::listen_address}:${puppetdb::params::listen_port}"],
  $version          = 'present',
  $ssl_cert_path    = undef,
  $ssl_key_path     = undef,
  $ssl_ca_cert_path = undef,
) inherits puppetdb::params {

  if !($puppetdb::params::puppetdb_version in ['present','absent'])
  and versioncmp($puppetdb::params::puppetdb_version, '4.0.0') >= 0 {
    err('puppet-client-tools is only compatible with PuppetDB 4.0.0 and greater')
  }

  $puppetdb_cli_config = "${confdir}/puppetdb.conf"
  $_puppetdb_cli_config = { 'puppetdb' =>  {
    'server_urls' => $server_urls,
    'cacert'      => $ssl_ca_cert_path,
    'cert'        => $ssl_cert_path,
    'key'         => $ssl_key_path,
    }
  }

  package { 'puppet-client-tools':
    ensure => $version,
  }

  file { $puppetdb_cli_config:
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    content => inline_template('<%= @_puppetdb_cli_config.to_json %>'),
    require => Package['puppet-client-tools'],
  }
}
