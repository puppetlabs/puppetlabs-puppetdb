class puppetdb::server(
    $database              = 'embedded',
    $psqldatabase_host       = $puppetdb::params::psqldatabase_host,
    $psqldatabase_port       = $puppetdb::params::psqldatabase_port,
    $psqldatabase_username   = $puppetdb::params::psqldatabase_username,
    $psqldatabase_password   = $puppetdb::params::psqldatabase_password,  
    $psqldatabase            = $puppetdb::params::psqldatabase,
    $confdir               = $puppetdb::params::confdir,
    $gc_interval           = $puppetdb::params::gc_interval,
    $version               = 'present'
) inherits puppetdb::params {

    package { 'puppetdb':
        ensure  => present,
        notify => Service['puppetdb'],
    }
    
    file { "${confdir}/database.ini":
        ensure      => file,
        require     => Package['puppetdb'],
    }

    service { 'puppetdb':
        ensure => running,
        enable => true,
        require => File["${confdir}/database.ini"],
    }

    #Set the defaults
    Ini_setting {
        path    => "${confdir}/database.ini",
        require => File["${confdir}/database.ini"],
        notify => Service['puppetdb'],
    }

    if $database == 'embedded'{
        $classname = 'org.hsqldb.jdbcDriver'
        $subprotocol = 'hsqldb'
        $subname = 'file:/usr/share/puppetdb/db/db;hsqldb.tx=mvcc;sql.syntax_pgs=true'
    } elsif $database == 'postgres' {
        $classname = 'org.postgresql.Driver'
        $subprotocol = 'postgresql'
        $subname = "//${psqldatabase_host}:${psqldatabase_port}/${psqldatabase}"
    
        ##Only setup for postgres
        ini_setting {'puppetdb_psdatabase_username':
            ensure  => present,
            section => 'database',
            setting => 'username',
            value   => $psqldatabase_username,
        }

        ini_setting {'puppetdb_psdatabase_password':
            ensure  => present,
            section => 'database',
            setting => 'password',
            value   => $psqldatabase_password,
        }
    }
    
    ini_setting {'puppetdb_classname':
            ensure  => present,
            section => 'database',
            setting => 'classname',
            value   => $classname,
    }

    ini_setting {'puppetdb_subprotocol':
            ensure  => present,
            section => 'database',
            setting => 'subprotocol',
            value   => $subprotocol,
    }

    ini_setting {'puppetdb_pgs':
            ensure  => present,
            section => 'database',
            setting => 'syntax_pgs',
            value   => true,
    }

    ini_setting {'puppetdb_subname':
            ensure  => present,
            section => 'database',
            setting => 'subname',
            value   => $subname,
    }

    ini_setting {'puppetdb_gc_interval':
            ensure  => present,
            section => 'database',
            setting => 'gc-interval',
            value   => $gc_interval ,
    }
    
}