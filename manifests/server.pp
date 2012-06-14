class puppetdb::server(
    $database = 'embedded',
    $database_host = 'localhost',
    $puppetdb_conf_dir = $puppetdb::params::confdir
) inherits puppetdb::params {

    package { 'puppetdb':
        ensure => present,
    }

    file { 'puppetdb: database.ini':
        ensure      => file,
        path        => "${puppetdb_conf_dir}/database.ini",
        content     => template('puppetdb/server/database.ini.erb'),
        notify      => Service['puppetdb'],
    }

    service { "puppetdb":
        ensure => running,
        #ensure => stopped,
   }

    Package['puppetdb'] -> File['puppetdb: database.ini'] -> Service['puppetdb']
#    Package['puppetdb'] -> File['puppetdb: database.ini']

}