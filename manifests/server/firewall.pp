class puppetdb::server::firewall(
    $port                   = '',
    $http_port              = $puppetdb::params::listen_port,             
    $open_http_port         = $puppetdb::params::open_listen_port,
    $ssl_port               = $puppetdb::params::ssl_listen_port,
    $open_ssl_port          = $puppetdb::params::open_ssl_listen_port,
    $manage_redhat_firewall = $puppetdb::params::manage_redhat_firewall,
) inherits puppetdb::params {
  # TODO: figure out a way to make this not platform-specific; debian and ubuntu
  # have an out-of-the-box firewall configuration that seems trickier to manage.
  # TODO: the firewall module should be able to handle this itself
  if ($puppetdb::params::firewall_supported) {

    if ($manage_redhat_firewall) {
      notify {'Deprecation notice: `$manage_redhat_firewall` is deprecated in the `puppetdb::service::firewall` class and will be removed in a future version. Use `open_http_port` and `open_ssl_port` instead.':}

      if (!$open_ssl_port) {
        # If the new param isn't set, go ahead and set to the old for consistent backward compatibility.
        $open_ssl_port = $manage_redhat_firewall
      } else {
        fail('`$manage_redhat_firewall` and `$open_ssl_port` cannot both be specified.')
      }
    }

    exec { 'puppetdb-persist-firewall':
      command     => $puppetdb::params::persist_firewall_command,
      refreshonly => true,
    }

    Firewall {
      notify => Exec['puppetdb-persist-firewall']
    }
    
    if (port) {
      notify { 'Deprecation notice: `port` parameter will be removed in future versions of the puppetdb module. Please use ssl_port instead.': }
    }

    if (port && ssl_port) {
      fail('`port` and `ssl_port` cannot both be defined. `port` is deprecated in favor of `ssl_port`')
    }
    
    if ($open_http_port) {
      firewall { "${http_port} accept - puppetdb":
        port   => $http_port,
        proto  => 'tcp',
        action => 'accept',
      }
    } 

    if ($open_ssl_port) {
      firewall { "${ssl_port} accept - puppetdb":
        port   => $ssl_port,
        proto  => 'tcp',
        action => 'accept',
      }
    }
  }
}
