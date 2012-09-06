class puppetdb::params {
    # TODO: need to condition this based on whether we are a PE install or not
    
    $psqldatabase_host = 'localhost'
    $psqldatabase_port = '5432'
    $psqldatabase = 'puppetdb'
    $psqldatabase_username = 'puppetdb'
    $psqldatabase_password = 'puppetdb'
    $gc_interval = 60
    $confdir = '/etc/puppetdb/conf.d'
}