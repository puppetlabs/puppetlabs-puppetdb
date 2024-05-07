<!-- markdownlint-disable MD024 -->
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## [v8.1.0](https://github.com/puppetlabs/puppetlabs-puppetdb/tree/v8.1.0) - 2024-05-07

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppetdb/compare/v8.0.1...v8.1.0)

### Added

- Add a `puppetdb_version` fact with PuppetDB version [#404](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/404) ([rwaffen](https://github.com/rwaffen))
- Restrict configuration file permissions [#343](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/343) ([smortex](https://github.com/smortex))
- Hide passwords from output [#320](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/320) ([gfa](https://github.com/gfa))

### Fixed

- set encoding when creating the DB [#359](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/359) ([elfranne](https://github.com/elfranne))
- cron puppetdb-dlo-cleanup requires package [#321](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/321) ([glennaaldering](https://github.com/glennaaldering))

## [v8.0.1](https://github.com/puppetlabs/puppetlabs-puppetdb/tree/v8.0.1) - 2024-05-02

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppetdb/compare/v8.0.0...v8.0.1)

### Fixed

- Fix lower bound the of puppetlabs-postgresql dependency [#402](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/402) ([smortex](https://github.com/smortex))

## [v8.0.0](https://github.com/puppetlabs/puppetlabs-puppetdb/tree/v8.0.0) - 2024-04-30

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppetdb/compare/7.14.0...v8.0.0)

## [7.14.0](https://github.com/puppetlabs/puppetlabs-puppetdb/tree/7.14.0) - 2023-10-09

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppetdb/compare/7.13.0...7.14.0)

### Changed

- Drop EoL Debian 8/9 [#347](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/347) ([bastelfreak](https://github.com/bastelfreak))
- Drop EoL CentOS 6 [#346](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/346) ([bastelfreak](https://github.com/bastelfreak))

### Added

- Relax dependency requirements [#367](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/367) ([smortex](https://github.com/smortex))
- Allow newer dependencies [#364](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/364) ([saz](https://github.com/saz))
- Set owner of server config.ini to root [#358](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/358) ([ekohl](https://github.com/ekohl))

### Fixed

- Fix "has no parameter named 'puppetdb_user'" [#369](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/369) ([cocker-cc](https://github.com/cocker-cc))

## [7.13.0](https://github.com/puppetlabs/puppetlabs-puppetdb/tree/7.13.0) - 2023-04-19

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppetdb/compare/7.12.0...7.13.0)

### Fixed

- (PDB-5611) Update legacy facts to structured form [#362](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/362) ([austb](https://github.com/austb))

## [7.12.0](https://github.com/puppetlabs/puppetlabs-puppetdb/tree/7.12.0) - 2022-12-13

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppetdb/compare/7.11.0...7.12.0)

## [7.11.0](https://github.com/puppetlabs/puppetlabs-puppetdb/tree/7.11.0) - 2022-12-12

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppetdb/compare/7.10.0...7.11.0)

## [7.10.0](https://github.com/puppetlabs/puppetlabs-puppetdb/tree/7.10.0) - 2021-12-16

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppetdb/compare/7.9.0...7.10.0)

### Added

- (maint) Allow stdlib 8.0.0 [#335](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/335) ([smortex](https://github.com/smortex))
- (maint) Add support for Debian 11 [#334](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/334) ([smortex](https://github.com/smortex))
- (PDB-5052) Install PostgreSQL 11 for PDB > 7.0.0 [#333](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/333) ([oanatmaria](https://github.com/oanatmaria))

### Fixed

- Fix minimum version of puppetlabs/postgresql [#332](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/332) ([alexjfisher](https://github.com/alexjfisher))

## [7.9.0](https://github.com/puppetlabs/puppetlabs-puppetdb/tree/7.9.0) - 2021-06-24

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppetdb/compare/7.8.0...7.9.0)

### Added

- (maint) Add read-only user. [#330](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/330) ([Filipovici-Andrei](https://github.com/Filipovici-Andrei))
- allow current versions of inifile, firewall, stdlib [#327](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/327) ([kenyon](https://github.com/kenyon))

## [7.8.0](https://github.com/puppetlabs/puppetlabs-puppetdb/tree/7.8.0) - 2021-03-25

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppetdb/compare/7.7.1...7.8.0)

### Added

- (SERVER-2500) Allow puppetlabs-postgresql 7.x [#323](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/323) ([Zak-Kent](https://github.com/Zak-Kent))
- (PDB-4764) Agent SSL certificates are used for communication with PostgreSQL [#322](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/322) ([Filipovici-Andrei](https://github.com/Filipovici-Andrei))

## [7.7.1](https://github.com/puppetlabs/puppetlabs-puppetdb/tree/7.7.1) - 2020-12-15

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppetdb/compare/7.7.0...7.7.1)

### Fixed

- Fix MODULES-10876 - use new client platform [#315](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/315) ([duritong](https://github.com/duritong))

## [7.7.0](https://github.com/puppetlabs/puppetlabs-puppetdb/tree/7.7.0) - 2020-11-05

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppetdb/compare/7.6.0...7.7.0)

### Added

- (PDB-4945) Default to json fact cache [#312](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/312) ([joshcooper](https://github.com/joshcooper))
- Add options to set the source of the ssl certs [#258](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/258) ([edestecd](https://github.com/edestecd))

## [7.6.0](https://github.com/puppetlabs/puppetlabs-puppetdb/tree/7.6.0) - 2020-09-02

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppetdb/compare/7.5.0...7.6.0)

### Added

- Database migrate option [#311](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/311) ([csmithATsquiz](https://github.com/csmithATsquiz))

## [7.5.0](https://github.com/puppetlabs/puppetlabs-puppetdb/tree/7.5.0) - 2020-06-10

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppetdb/compare/7.4.0...7.5.0)

### Added

- Allow custom JAVA_BIN path [#307](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/307) ([bastelfreak](https://github.com/bastelfreak))
- (MODULES-10675) enable facts-blacklist parameter in database.ini [#305](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/305) ([maxadamo](https://github.com/maxadamo))
- Add node-purge-gc-batch-limit as configurable [#303](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/303) ([synical](https://github.com/synical))
- (PDB-2578) Allow the database password to be unmanaged [#301](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/301) ([natemccurdy](https://github.com/natemccurdy))
- Support CentOS 8, OracleLinux 8 and Debian 10 & support pl/inifile 4.x [#300](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/300) ([ekohl](https://github.com/ekohl))
- Create enable_storeconfigs option for puppet::master::config [#298](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/298) ([gcoxmoz](https://github.com/gcoxmoz))

## [7.4.0](https://github.com/puppetlabs/puppetlabs-puppetdb/tree/7.4.0) - 2019-08-06

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppetdb/compare/7.3.0...7.4.0)

## [7.3.0](https://github.com/puppetlabs/puppetlabs-puppetdb/tree/7.3.0) - 2019-06-14

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppetdb/compare/7.2.0...7.3.0)

### Added

- allow newer versions of dependencies [#295](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/295) ([mmoll](https://github.com/mmoll))

## [7.2.0](https://github.com/puppetlabs/puppetlabs-puppetdb/tree/7.2.0) - 2019-05-17

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppetdb/compare/7.1.0...7.2.0)

### Added

- Allow inifile 3.x and postgresql 7.x [#290](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/290) ([ekohl](https://github.com/ekohl))

## [7.1.0](https://github.com/puppetlabs/puppetlabs-puppetdb/tree/7.1.0) - 2018-10-02

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppetdb/compare/7.0.1...7.1.0)

### Added

- (PDB-4092) Use vardir prefix for DLO path [#285](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/285) ([austb](https://github.com/austb))

## [7.0.1](https://github.com/puppetlabs/puppetlabs-puppetdb/tree/7.0.1) - 2018-07-30

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppetdb/compare/7.0.0...7.0.1)

## [7.0.0](https://github.com/puppetlabs/puppetlabs-puppetdb/tree/7.0.0) - 2018-07-26

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppetdb/compare/6.0.2...7.0.0)

### Changed

- Setup for 7.0.0 release [#279](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/279) ([Zak-Kent](https://github.com/Zak-Kent))

### Added

- Add support for DLO automatic cleanup [#278](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/278) ([bastelfreak](https://github.com/bastelfreak))

### Fixed

- (FIX) Switch DLO to Puppet cron from cron::job [#281](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/281) ([austb](https://github.com/austb))

## [6.0.2](https://github.com/puppetlabs/puppetlabs-puppetdb/tree/6.0.2) - 2017-11-06

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppetdb/compare/6.0.1...6.0.2)

### Added

- (PDB-3654) bump version and ini file dep [#274](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/274) ([Zak-Kent](https://github.com/Zak-Kent))
- add explicit dependency db -> extension. [#272](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/272) ([pgassmann](https://github.com/pgassmann))
- (maint) bump inifile dependency [#268](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/268) ([eputnam](https://github.com/eputnam))

## [6.0.1](https://github.com/puppetlabs/puppetlabs-puppetdb/tree/6.0.1) - 2017-07-05

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppetdb/compare/6.0.0...6.0.1)

## [6.0.0](https://github.com/puppetlabs/puppetlabs-puppetdb/tree/6.0.0) - 2017-07-05

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppetdb/compare/5.1.2...6.0.0)

### Changed

- Default to postgres 9.6 [#265](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/265) ([mullr](https://github.com/mullr))

### Added

- (PDB-3587) Add puppetlabs-postgresql 5.x support and integrate rspec-puppetfacts [#260](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/260) ([dhollinger](https://github.com/dhollinger))
- Add disable-update-checking parameter [#257](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/257) ([baurmatt](https://github.com/baurmatt))
- (PDB-3318) Better defaults for node-ttl, node-purge-ttl [#254](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/254) ([mullr](https://github.com/mullr))
- enable the master service when it is not defined [#253](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/253) ([tampakrap](https://github.com/tampakrap))
- add option to customize cipher suites in jetty [#247](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/247) ([selyx](https://github.com/selyx))
- Add support for Ruby 2.3.1 [#246](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/246) ([ghoneycutt](https://github.com/ghoneycutt))
- (PDB-3060) Add concurrent-writes parameter. [#244](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/244) ([aperiodic](https://github.com/aperiodic))
- set mode 0644 for routes.yaml [#238](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/238) ([tampakrap](https://github.com/tampakrap))
- (PDB-2660) Restart Puppet master after enabling reporting [#234](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/234) ([ajroetker](https://github.com/ajroetker))
- Manage the pool size configuration parameters in database.ini [#232](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/232) ([kpaulisse](https://github.com/kpaulisse))
- (PDB-2571) Ensure puppetdb.ini file has correct permissions [#228](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/228) ([kbarber](https://github.com/kbarber))
- Update postgresql.pp with postgresql contrib package [#225](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/225) ([PascalBourdier](https://github.com/PascalBourdier))

### Fixed

- Fix duplicate resource errors for puppet service due to parse order [#250](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/250) ([kpaulisse](https://github.com/kpaulisse))
- FIX: Unbreak on OpenBSD [#233](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/233) ([buzzdeee](https://github.com/buzzdeee))
- (PDB-2696) Remove the dependency cycle cause by typo [#231](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/231) ([ajroetker](https://github.com/ajroetker))

## [5.1.2](https://github.com/puppetlabs/puppetlabs-puppetdb/tree/5.1.2) - 2016-03-14

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppetdb/compare/5.1.1...5.1.2)

## [5.1.1](https://github.com/puppetlabs/puppetlabs-puppetdb/tree/5.1.1) - 2016-02-09

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppetdb/compare/5.1.0...5.1.1)

## [5.1.0](https://github.com/puppetlabs/puppetlabs-puppetdb/tree/5.1.0) - 2016-02-09

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppetdb/compare/5.0.0...5.1.0)

### Added

- Restrict access to the Puppet master by default [#215](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/215) ([michaelweiser](https://github.com/michaelweiser))
- Add option to disable cleartext HTTP port [#214](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/214) ([michaelweiser](https://github.com/michaelweiser))
- (PDB-1430) overwritable java_args [#210](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/210) ([wkalt](https://github.com/wkalt))
- (PDB-1913) manage vardir [#209](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/209) ([wkalt](https://github.com/wkalt))
- (PDB-1415) Add jdbc_ssl_properties parameter [#206](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/206) ([mullr](https://github.com/mullr))

### Fixed

- MODULES-2488 Use dport instead of the now deprecated port parameter [#205](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/205) ([roman-mueller](https://github.com/roman-mueller))
- Fix unmanaged postgresql database port [#204](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/204) ([earsdown](https://github.com/earsdown))

## [5.0.0](https://github.com/puppetlabs/puppetlabs-puppetdb/tree/5.0.0) - 2015-07-08

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppetdb/compare/4.3.0...5.0.0)

## [4.3.0](https://github.com/puppetlabs/puppetlabs-puppetdb/tree/4.3.0) - 2015-06-26

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppetdb/compare/4.2.1...4.3.0)

### Changed

- (PDB-1657) Manage Postgres repos by default [#197](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/197) ([ajroetker](https://github.com/ajroetker))
- (PDB-1035) Add default PuppetDB root context [#181](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/181) ([ajroetker](https://github.com/ajroetker))

### Added

- (PDB-1455) Provide mechanism for modifying default HSQLDB path [#185](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/185) ([kbarber](https://github.com/kbarber))
- Enable the module to manage entries in $confdir/config.ini [#176](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/176) ([buzzdeee](https://github.com/buzzdeee))

### Fixed

- (PDB-1467) Ordering problem with read_database_ini [#180](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/180) ([kbarber](https://github.com/kbarber))

## [4.2.1](https://github.com/puppetlabs/puppetlabs-puppetdb/tree/4.2.1) - 2015-04-08

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppetdb/compare/4.2.0...4.2.1)

## [4.2.0](https://github.com/puppetlabs/puppetlabs-puppetdb/tree/4.2.0) - 2015-04-02

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppetdb/compare/4.1.0...4.2.0)

### Added

- (PDB-1353) Use settings::confdir for puppet_confdir [#172](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/172) ([johnduarte](https://github.com/johnduarte))
- add FreeBSD support [#171](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/171) ([mmoll](https://github.com/mmoll))
- Allow puppetdb to be configure for masterless conf [#163](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/163) ([Spredzy](https://github.com/Spredzy))
- add ability to manage postgres repo [#162](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/162) ([bastelfreak](https://github.com/bastelfreak))
- Restart the service if certificates change [#158](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/158) ([dalen](https://github.com/dalen))
- Make database validation optional [#157](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/157) ([robinbowes](https://github.com/robinbowes))
- Show scheme (http/https) in puppetdb connection errors [#155](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/155) ([sathieu](https://github.com/sathieu))

### Fixed

- (bugfix) Use test_url in connection validator for puppetdb [#169](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/169) ([ajroetker](https://github.com/ajroetker))
- Fix separator in module name in metadata.json [#164](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/164) ([njm506](https://github.com/njm506))
- Remove unused parameters [#161](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/161) ([ekohl](https://github.com/ekohl))
- add missing param manage_firewall [#160](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/160) ([bastelfreak](https://github.com/bastelfreak))

## [4.1.0](https://github.com/puppetlabs/puppetlabs-puppetdb/tree/4.1.0) - 2014-11-17

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppetdb/compare/4.0.0...4.1.0)

### Added

- Allow only TLS - Fixes POODLE CVE-2014-3566 [#150](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/150) ([ghoneycutt](https://github.com/ghoneycutt))

### Fixed

- Remove invisible unicode character to prevent "invalid byte sequence in ... [#149](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/149) ([stefanandres](https://github.com/stefanandres))
- Fix detection of a PE-based PuppetDB [#146](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/146) ([seanmil](https://github.com/seanmil))

## [4.0.0](https://github.com/puppetlabs/puppetlabs-puppetdb/tree/4.0.0) - 2014-09-16

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppetdb/compare/3.0.1...4.0.0)

### Changed

- do not manage firewall for postgres, puppetlabs/postgres module from [#135](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/135) ([buzzdeee](https://github.com/buzzdeee))

### Added

- OpenBSD support [#136](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/136) ([buzzdeee](https://github.com/buzzdeee))
- Add read-database support [#132](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/132) ([tdevelioglu](https://github.com/tdevelioglu))
- Allow set manage_server in init class [#131](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/131) ([baurmatt](https://github.com/baurmatt))
- implement max_threads option for jetty [#130](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/130) ([stefanandres](https://github.com/stefanandres))
- Allow more flexible routes configuration [#127](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/127) ([dalen](https://github.com/dalen))
- Add strict_variables support when puppetdb is not on puppetmaster [#126](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/126) ([mcanevet](https://github.com/mcanevet))
- Use $is_pe for PE determination [#122](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/122) ([reidmv](https://github.com/reidmv))
- Parameter to not manage postgresql server [#121](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/121) ([jantman](https://github.com/jantman))
- Adding option to disable management of the firewall [#119](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/119) ([nibalizer](https://github.com/nibalizer))

### Fixed

- Fixed read-database parameters in class puppetdb [#134](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/134) ([tdevelioglu](https://github.com/tdevelioglu))
- Ensure db and db users created before validation [#125](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/125) ([rickerc](https://github.com/rickerc))
- Fix is_pe declaration so it works without is_pe [#123](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/123) ([kbarber](https://github.com/kbarber))

## [3.0.1](https://github.com/puppetlabs/puppetlabs-puppetdb/tree/3.0.1) - 2014-02-11

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppetdb/compare/3.0.0...3.0.1)

### Changed

- Use the /v2 metrics endpoint instead of /metrics [#116](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/116) ([kbarber](https://github.com/kbarber))

### Added

- Define parameter in puppetdb class to define postgres listen address [#112](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/112) ([adrianlzt](https://github.com/adrianlzt))
- Concat update [#101](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/101) ([jhoblitt](https://github.com/jhoblitt))

### Fixed

- Fix puppetlabs#106 and one other bug when disable_ssl = true [#107](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/107) ([ebarrere](https://github.com/ebarrere))
- fix validation regular expressions [#100](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/100) ([ScottDuckworth](https://github.com/ScottDuckworth))

## [3.0.0](https://github.com/puppetlabs/puppetlabs-puppetdb/tree/3.0.0) - 2013-10-28

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppetdb/compare/2.0.0...3.0.0)

### Added

- (GH-93) Switch to using puppetlabs-postgresql 3.x [#94](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/94) ([kbarber](https://github.com/kbarber))
- (GH-91) Update to use rspec-system-puppet 2.x [#92](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/92) ([kbarber](https://github.com/kbarber))
- Add soft_write_failure to puppetdb.conf [#89](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/89) ([ghoneycutt](https://github.com/ghoneycutt))
- Add switch to configure database SSL connection [#80](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/80) ([stdietrich](https://github.com/stdietrich))

## [2.0.0](https://github.com/puppetlabs/puppetlabs-puppetdb/tree/2.0.0) - 2013-10-18

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppetdb/compare/1.5.1...2.0.0)

### Added

- Enable service control for puppetdb [#81](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/81) ([ak0ska](https://github.com/ak0ska))
- add archlinux support [#79](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/79) ([aboe76](https://github.com/aboe76))
- Make database_password an optional parameter [#78](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/78) ([nicklewis](https://github.com/nicklewis))

### Fixed

- (GH-73) Switch to puppetlabs/inifile from cprice/inifile [#74](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/74) ([kbarber](https://github.com/kbarber))

## [1.5.1](https://github.com/puppetlabs/puppetlabs-puppetdb/tree/1.5.1) - 2013-08-12

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppetdb/compare/1.6.0...1.5.1)

## [1.6.0](https://github.com/puppetlabs/puppetlabs-puppetdb/tree/1.6.0) - 2013-08-09

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppetdb/compare/1.5.0...1.6.0)

### Added

- Add missing parameters for 1.4.0 release [#76](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/76) ([kbarber](https://github.com/kbarber))

## [1.5.0](https://github.com/puppetlabs/puppetlabs-puppetdb/tree/1.5.0) - 2013-07-18

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppetdb/compare/1.4.0...1.5.0)

### Changed

- Fix dependency for stdlib for 'downcase' [#70](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/70) ([kbarber](https://github.com/kbarber))

### Added

- Minor tweaks to make the module support SUSE [#71](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/71) ([cprice404](https://github.com/cprice404))
- Allow puppetdb conn validation when ssl is disabled [#68](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/68) ([bodepd](https://github.com/bodepd))
- Add support for enabling puppetdb report processor [#64](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/64) ([cprice404](https://github.com/cprice404))

## [1.4.0](https://github.com/puppetlabs/puppetlabs-puppetdb/tree/1.4.0) - 2013-05-28

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppetdb/compare/1.2.1...1.4.0)

### Changed

- Use fqdn for ssl listen address instead of clientcert [#63](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/63) ([cprice404](https://github.com/cprice404))
- Increase default report-ttl to 14d [#60](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/60) ([cprice404](https://github.com/cprice404))

### Added

- Add support for enabling puppetdb report processor [#64](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/64) ([cprice404](https://github.com/cprice404))
- Separate DB instance and DB user creation [#61](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/61) ([dalen](https://github.com/dalen))
- Add option to disable SSL in Jetty [#52](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/52) ([christianberg](https://github.com/christianberg))
- allows for 0 _ttl's without time signifier and enables tests [#50](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/50) ([ghoneycutt](https://github.com/ghoneycutt))
- Support for remote puppetdb [#41](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/41) ([fhrbek](https://github.com/fhrbek))
- Added support for Java VM options [#37](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/37) ([kbrezina](https://github.com/kbrezina))

## [1.2.1](https://github.com/puppetlabs/puppetlabs-puppetdb/tree/1.2.1) - 2013-04-08

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppetdb/compare/1.2.0...1.2.1)

### Added

- Add unit suffix to TTL settings to avoid issue #20099 [#45](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/45) ([domcleal](https://github.com/domcleal))

## [1.2.0](https://github.com/puppetlabs/puppetlabs-puppetdb/tree/1.2.0) - 2013-04-07

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppetdb/compare/1.1.5...1.2.0)

### Added

- Add params and ini_settings for node/report/purge ttls [#35](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/35) ([nicklewis](https://github.com/nicklewis))

## [1.1.5](https://github.com/puppetlabs/puppetlabs-puppetdb/tree/1.1.5) - 2013-04-04

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppetdb/compare/1.1.4...1.1.5)

## [1.1.4](https://github.com/puppetlabs/puppetlabs-puppetdb/tree/1.1.4) - 2013-01-17

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppetdb/compare/1.1.3...1.1.4)

## [1.1.3](https://github.com/puppetlabs/puppetlabs-puppetdb/tree/1.1.3) - 2013-01-15

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppetdb/compare/1.1.2...1.1.3)

### Added

- 17594 - PuppetDB - Add ability to set standard host listen address and open firewall to standard port [#22](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/22) ([dblessing](https://github.com/dblessing))

## [1.1.2](https://github.com/puppetlabs/puppetlabs-puppetdb/tree/1.1.2) - 2012-10-26

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppetdb/compare/1.1.1...1.1.2)

## [1.1.1](https://github.com/puppetlabs/puppetlabs-puppetdb/tree/1.1.1) - 2012-10-26

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppetdb/compare/1.1.0...1.1.1)

## [1.1.0](https://github.com/puppetlabs/puppetlabs-puppetdb/tree/1.1.0) - 2012-10-24

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppetdb/compare/1.0.3...1.1.0)

### Added

- Fix embedded db setup in Puppet Enterprise [#19](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/19) ([reidmv](https://github.com/reidmv))
- Make puppetdb startup timeout configurable [#18](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/18) ([cprice404](https://github.com/cprice404))
- Add condition to detect PE installations and provide different parameters [#15](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/15) ([hunner](https://github.com/hunner))
- Add parameters to enable usage of enterprise versions of PuppetDB [#11](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/11) ([cprice404](https://github.com/cprice404))
- Add a parameter for restarting puppet master [#9](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/9) ([cprice404](https://github.com/cprice404))

## [1.0.3](https://github.com/puppetlabs/puppetlabs-puppetdb/tree/1.0.3) - 2012-09-23

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppetdb/compare/1.0.2...1.0.3)

### Added

- Add a parameter for restarting puppet master [#9](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/9) ([cprice404](https://github.com/cprice404))

## [1.0.2](https://github.com/puppetlabs/puppetlabs-puppetdb/tree/1.0.2) - 2012-09-21

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppetdb/compare/1.0.1...1.0.2)

## [1.0.1](https://github.com/puppetlabs/puppetlabs-puppetdb/tree/1.0.1) - 2012-09-20

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppetdb/compare/1.0...1.0.1)

### Fixed

- Fix duplicate stanza in database_ini.pp [#8](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/8) ([cprice404](https://github.com/cprice404))
- Bug/master/db ini wrong db name [#6](https://github.com/puppetlabs/puppetlabs-puppetdb/pull/6) ([cprice404](https://github.com/cprice404))

## [1.0](https://github.com/puppetlabs/puppetlabs-puppetdb/tree/1.0) - 2012-09-19

[Full Changelog](https://github.com/puppetlabs/puppetlabs-puppetdb/compare/84a2c66542172f7f033bf39798c8fe866c07b449...1.0)
