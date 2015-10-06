# Manages the routes configuration file on the master. See README.md for more
# details.
class puppetdb::master::routes (
  $puppet_confdir = $puppetdb::params::puppet_confdir,
  $masterless     = $puppetdb::params::masterless,
  $routes         = {
    'master' => {
      'facts' => {
        'terminus' => 'puppetdb',
        'cache'    => 'yaml',
      }
    }
  }
) inherits puppetdb::params {

  if $masterless {
    $routes_real = {
      'apply' => {
        'catalog' => {
          'terminus' => 'compiler',
          'cache'    => 'puppetdb',
        },
        'facts'   => {
          'terminus' => 'facter',
          'cache'    => 'puppetdb_apply',
        }
      }
    }
  } else {
    $routes_real = $routes
  }

  # TODO: this will overwrite any existing routes.yaml;
  #  to handle this properly we should just be ensuring
  #  that the proper settings exist, but to do that we'd need
  #  to parse the yaml file and rewrite it, dealing with indentation issues etc
  #  I don't think there is currently a puppet module or an augeas lens for
  #  this.
  file { "${puppet_confdir}/routes.yaml":
    ensure  => file,
    content => template('puppetdb/routes.yaml.erb'),
  }
}
