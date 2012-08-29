class puppetdb::server(
    $database              = 'embedded',
    $psdatabase_host       = $puppetdb::params::psdatabase_host,
    $psdatabase_port       = $puppetdb::params::psdatabase_port,
    $psdatabase_username   = $puppetdb::params::psdatabase_username,
    $psdatabase_password   = $puppetdb::params::psdatabase_password,  
    $psdatabase            = $puppetdb::params::psdatabase_psdatabase,
    $confdir               = $puppetdb::params::confdir,
    $gc_interval           = $puppetdb::params::gc_interval
) inherits puppetdb::params {

    package { 'puppetdb':
        ensure  => present,
        notifty => Service['puppetdb'],
    }
    
    file { "{confdir}/database.ini":
        ensure      => file,
        path        => $puppetdb_ini_file,
        require     => Package['puppetdb'],
    }

    service { 'puppetdb':
        ensure => running,
        require => File['puppetdb: database.ini'],
    }

    #Set the defaults
    Ini_setting {
        path    => "${confdir}/database.ini",
        require => File['{confdir}/database.ini'],
        notifty => Service['puppetdb'],
    }

    if $database == 'embedded'{
        $classname = 'org.hsqldb.jdbcDriver'
        $subprotocol = 'hsqldb'
        $subname = 'file:/usr/share/puppetdb/db/db;hsqldb.tx=mvcc;sql.syntax_pgs=true'
    } elsif $database == 'postgres' {
        $classname = 'org.postgresql.Driver'
        $subprotocol = 'postgresql'
        $subname = "//#${psdatabase_host}:${psdatabase_port}/${psdatabase}"
    
        ##Only setup for postgres
        ini_setting {'puppetdb_psdatabase_username':
            ensure  => present,
            section => 'database',
            setting => 'username',
            value   => $psdatabase_username,
        }

        ini_setting {'puppetdb_psdatabase_username':
            ensure  => present,
            section => 'database',
            setting => 'password',
            value   => $psdatabase_password,
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
            setting => 'gc-interval ',
            value   => $gc_interval ,
    }
    
}