# @summary manage puppetdb read_database ini
#
# @api private
class puppetdb::server::read_database (
  Optional[Stdlib::Host]                                               $read_database_host     = $puppetdb::params::read_database_host,
  Variant[Stdlib::Port::User, Pattern[/\A[0-9]+\Z/]]                   $read_database_port     = $puppetdb::params::read_database_port,
  String[1]                                                            $read_database_username = $puppetdb::params::read_database_username,
  Variant[String[1], Sensitive[String[1]]]                             $read_database_password = $puppetdb::params::read_database_password,
  String[1]                                                            $read_database_name     = $puppetdb::params::read_database_name,
  Boolean                                                              $manage_db_password     = $puppetdb::params::manage_read_db_password,
  Variant[String[0], Boolean[false]]                                   $jdbc_ssl_properties    = $puppetdb::params::read_database_jdbc_ssl_properties,
  Boolean                                                              $database_validate      = $puppetdb::params::read_database_validate,
  Variant[Integer[0], Pattern[/\A[0-9]+\Z/]]                           $conn_max_age           = $puppetdb::params::read_conn_max_age,
  Variant[Integer[0], Pattern[/\A[0-9]+\Z/]]                           $conn_lifetime          = $puppetdb::params::read_conn_lifetime,
  Stdlib::Absolutepath                                                 $confdir                = $puppetdb::params::confdir,
  String[1]                                                            $puppetdb_group         = $puppetdb::params::puppetdb_group,
  Optional[Variant[Integer[0], Enum['absent'], Pattern[/\A[0-9]+\Z/]]] $database_max_pool_size = $puppetdb::params::read_database_max_pool_size,
  Boolean                                                              $postgresql_ssl_on      = $puppetdb::params::postgresql_ssl_on,
  Stdlib::Absolutepath                                                 $ssl_cert_path          = $puppetdb::params::ssl_cert_path,
  Stdlib::Absolutepath                                                 $ssl_key_pk8_path       = $puppetdb::params::ssl_key_pk8_path,
  Stdlib::Absolutepath                                                 $ssl_ca_cert_path       = $puppetdb::params::ssl_ca_cert_path
) inherits puppetdb::params {
  if $read_database_host != undef {
    if str2bool($database_validate) {
      # Validate the database connection.  If we can't connect, we want to fail
      # and skip the rest of the configuration, so that we don't leave puppetdb
      # in a broken state.
      #
      # NOTE:
      # Because of a limitation in the postgres module this will break with
      # a duplicate declaration if read and write database host+name are the
      # same.
      class { 'puppetdb::server::validate_read_db':
        database_host     => $read_database_host,
        database_port     => $read_database_port,
        database_username => $read_database_username,
        database_password => $read_database_password,
        database_name     => $read_database_name,
      }
    }

    $read_database_ini = "${confdir}/read_database.ini"

    file { $read_database_ini:
      ensure => file,
      owner  => 'root',
      group  => $puppetdb_group,
      mode   => '0640',
    }

    $file_require = File[$read_database_ini]
    $ini_setting_require = str2bool($database_validate) ? {
      false   => $file_require,
      default => [$file_require, Class['puppetdb::server::validate_read_db']],
    }
    # Set the defaults
    Ini_setting {
      path    => $read_database_ini,
      ensure  => present,
      section => 'read-database',
      require => $ini_setting_require,
    }

    if !empty($jdbc_ssl_properties) {
      $database_suffix = $jdbc_ssl_properties
    }
    else {
      $database_suffix = ''
    }

    $subname_default = "//${read_database_host}:${read_database_port}/${read_database_name}${database_suffix}"

    if $postgresql_ssl_on and !empty($jdbc_ssl_properties) {
      fail("Variables 'postgresql_ssl_on' and 'jdbc_ssl_properties' can not be used at the same time!")
    }

    if $postgresql_ssl_on {
      $subname = @("EOT"/L)
        ${subname_default}?\
        ssl=true&sslfactory=org.postgresql.ssl.LibPQFactory&\
        sslmode=verify-full&sslrootcert=${ssl_ca_cert_path}&\
        sslkey=${ssl_key_pk8_path}&sslcert=${ssl_cert_path}\
        | EOT
    } else {
      $subname = $subname_default
    }

    ini_setting { 'puppetdb_read_database_username':
      setting => 'username',
      value   => $read_database_username,
    }

    if $read_database_password != undef and $manage_db_password {
      ini_setting { 'puppetdb_read_database_password':
        setting   => 'password',
        value     => $read_database_password,
        show_diff => false,
      }
    }

    ini_setting { 'puppetdb_read_pgs':
      setting => 'syntax_pgs',
      value   => true,
    }

    ini_setting { 'puppetdb_read_subname':
      setting => 'subname',
      value   => $subname,
    }

    ini_setting { 'puppetdb_read_conn_max_age':
      setting => 'conn-max-age',
      value   => $conn_max_age,
    }

    ini_setting { 'puppetdb_read_conn_lifetime':
      setting => 'conn-lifetime',
      value   => $conn_lifetime,
    }

    if $puppetdb::params::database_max_pool_size_setting_name != undef {
      if $database_max_pool_size == 'absent' {
        ini_setting { 'puppetdb_read_database_max_pool_size':
          ensure  => absent,
          setting => $puppetdb::params::database_max_pool_size_setting_name,
        }
      } elsif $database_max_pool_size != undef {
        ini_setting { 'puppetdb_read_database_max_pool_size':
          setting => $puppetdb::params::database_max_pool_size_setting_name,
          value   => $database_max_pool_size,
        }
      }
    } else {
      file { "${confdir}/read_database.ini":
        ensure => absent,
      }
    }
  } else {
    file { "${confdir}/read_database.ini":
      ensure => absent,
    }
  }
}
