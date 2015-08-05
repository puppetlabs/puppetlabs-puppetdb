class puppetdb::globals (
  $database                     = 'postgres',
  ) {

  if !($::osfamily in ['RedHat', 'Suse', 'Archlinux', 'Debian', 'OpenBSD', 'FreeBSD']) {
    fail("${module_name} does not support your osfamily ${::osfamily}")
  }

}
