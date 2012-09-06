  # Class: puppetdb::dbterminus
  #
  # This class installs and configures the puppetdb terminus pacakge
  #
  # Parameters:
  #   ['puppet_confdir']    - The config directory of puppet
  #   ['dbport']            - The port of the puppetdb
  #   ['dbserver']          - The dns name of the puppetdb server
  #
  # Actions:
  # - Configures the puppetdb terminus package
  #
  # Requires:
  # - Inifile
  #
  # Sample Usage:
  #   class { 'puppet::dbterminus':
  #       puppet_confdir             => '/etc/puppet/',
  #       dbport                     => 8081,
  #       dbserver                   => 'localhost'
  #   }
  #
  class puppetdb::dbterminus($puppet_confdir, $dbport, $dbserver)
  {
    package { 'puppetdb-terminus':
      ensure  => present,
    }

    # TODO: this will overwrite any existing routes.yaml;
    #  to handle this properly we should just be ensuring
    #  that the proper lines exist
    file { "${puppet_confdir}/routes.yaml":
      ensure      => file,
      source      => 'puppet:///modules/puppet/routes.yaml',
      require     => Package['puppetdb-terminus'],
    }

    file { "${puppet_confdir}/puppetdb.conf":
      ensure      => file,
      require     => File["${puppet_confdir}/routes.yaml"],
    }

    ini_setting {'puppetterminusserver':
      ensure  => present,
      section => 'main',
      setting => 'server',
      path    => "${puppet_confdir}/puppetdb.conf",
      value   => $dbserver,
      require => File["${puppet_confdir}/puppetdb.conf"],
    }

    ini_setting {'puppetterminusport':
      ensure  => present,
      section => 'main',
      setting => 'port',
      path    => "${puppet_confdir}/puppetdb.conf",
      value   => $dbport,
      require => File["${puppet_confdir}/puppetdb.conf"],
    }
  }
