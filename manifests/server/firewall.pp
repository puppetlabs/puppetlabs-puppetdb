# @summary manage puppetdb firewall rules
#
# @api private
class puppetdb::server::firewall (
  Variant[Stdlib::Port::Unprivileged, Pattern[/\A[0-9]+\Z/]] $http_port      = $puppetdb::params::listen_port,
  Boolean                                                    $open_http_port = $puppetdb::params::open_listen_port,
  Variant[Stdlib::Port::Unprivileged, Pattern[/\A[0-9]+\Z/]] $ssl_port       = $puppetdb::params::ssl_listen_port,
  Optional[Boolean]                                          $open_ssl_port  = $puppetdb::params::open_ssl_listen_port,
) inherits puppetdb::params {
  include firewall

  if ($open_http_port) {
    firewall { "${http_port} accept - puppetdb":
      dport => $http_port,
      proto => 'tcp',
      jump  => 'accept',
    }
  }

  if ($open_ssl_port) {
    firewall { "${ssl_port} accept - puppetdb":
      dport => $ssl_port,
      proto => 'tcp',
      jump  => 'accept',
    }
  }
}
