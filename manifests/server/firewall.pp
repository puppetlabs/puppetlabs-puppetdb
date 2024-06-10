# @summary manage puppetdb firewall rules
#
# @api private
class puppetdb::server::firewall (
  $http_port      = $puppetdb::params::listen_port,
  $open_http_port = $puppetdb::params::open_listen_port,
  $ssl_port       = $puppetdb::params::ssl_listen_port,
  $open_ssl_port  = $puppetdb::params::open_ssl_listen_port,
) inherits puppetdb::params {
  if ($open_http_port) {
    include firewall

    firewall { "${http_port} accept - puppetdb":
      dport => $http_port,
      proto => 'tcp',
      jump  => 'accept',
    }
  }

  if ($open_ssl_port) {
    include firewall

    firewall { "${ssl_port} accept - puppetdb":
      dport => $ssl_port,
      proto => 'tcp',
      jump  => 'accept',
    }
  }
}
