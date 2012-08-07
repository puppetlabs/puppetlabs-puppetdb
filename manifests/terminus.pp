class puppetdb::terminus(
    $puppetdb_host = $settings::certname
) {
    package { "puppetdb-terminus":
        ensure => present,
    }

    # TODO: this will overwrite any existing routes.yaml;
    #  to handle this properly we should just be ensuring
    #  that the proper lines exist
    $routes_file = "${settings::confdir}/routes.yaml"
    file { "$routes_file":
        ensure      => file,
        content     => template('puppetdb/terminus/routes.yaml.erb'),
        require     => Class['puppet::master'],
        notify      => $::puppet::master::service_notify
    }

    $notify_exec = "notify: puppet.conf changes required"
    $puppetdb_conf_file = "${settings::confdir}/puppetdb.conf"
    file { "$puppetdb_conf_file":
        ensure      => file,
        content     => template('puppetdb/terminus/puppetdb.conf.erb'),
        notify      => $::puppet::master::service_notify
    }
        
    Package["puppetdb-terminus"] -> File[$routes_file] -> File[$puppetdb_conf_file]
}