class puppetdb::terminus(
    $puppetdb_host = $settings::certname
) {
    package { "puppetdb-terminus":
        ensure => present,
    }

    package { "puppetmaster":
        ensure => present,
    }

    service { "puppetmaster":
        ensure => running,
    }

    # TODO: this will overwrite any existing routes.yaml;
    #  to handle this properly we should just be ensuring
    #  that the proper lines exist
    $routes_file = "${settings::confdir}/routes.yaml"
    file { "$routes_file":
        ensure      => file,
        content     => template('puppetdb/terminus/routes.yaml.erb'),
        notify      => Service['puppetmaster'],
    }

    $notify_exec = "notify: puppet.conf changes required"
    $puppetdb_conf_file = "${settings::confdir}/puppetdb.conf"
    file { "$puppetdb_conf_file":
        ensure      => file,
        content     => template('puppetdb/terminus/puppetdb.conf.erb'),
        notify      => [Service['puppetmaster'], Exec[$notify_exec]]
    }

    # TODO: we also need to make some small changes to puppet.conf, but
    #  that requires the ability to manipulate an .ini file, which
    #  we can't easily accomplish at this point.  This exec is here
    #  to notify the users of the situation.  Can't use a real 'notify'
    #  because we only want this to appear on refresh.
    $puppet_conf_changes_msg = "
        Almost there!  To finish, you'll need to add the following lines to
        your puppet.conf file, in the [main] section:

            server=${settings::certname}
            storeconfigs=true
            storeconfigs_backend=puppetdb

        Then you should be able to run 'puppet agent --test' to exercise
        your puppetdb installation.

        "
    exec { $notify_exec:
        refreshonly => true,
        path        => '/bin:/usr/bin',
        command     => "echo \"$puppet_conf_changes_msg\"",
        logoutput   => true,
    }

    Package["puppetmaster"] ->
        Package["puppetdb-terminus"] ->
        File[$routes_file] ->
        File[$puppetdb_conf_file] ->
        Service["puppetmaster"]
}