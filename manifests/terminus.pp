class puppetdb::terminus(
    $puppetdb_host = $settings::certname,
    $puppetmaster_service = undef
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
        require     => Package['puppetdb-terminus'],
        notify      => $puppetmaster_service,
    }

    $notify_exec = "notify: puppet.conf changes required"
    $puppetdb_conf_file = "${settings::confdir}/puppetdb.conf"
    file { "$puppetdb_conf_file":
        ensure      => file,
        content     => template('puppetdb/terminus/puppetdb.conf.erb'),
        require     => File[$routes_file],
        notify      => $puppetmaster_service,
    }
}