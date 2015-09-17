require 'spec_helper'

describe 'puppetdb::server::database', :type => :class do
  context 'on a supported platform' do
    let(:facts) do
      {
        :osfamily                 => 'RedHat',
        :operatingsystem          => 'RedHat',
        :operatingsystemrelease   => '7.0',
        :fqdn                     => 'test.domain.local',
      }
    end

    it { should contain_class('puppetdb::server::database') }

    describe 'when using default values' do
      it { should contain_ini_setting('puppetdb_psdatabase_username').
        with(
             'ensure'  => 'present',
             'path'    => '/etc/puppetlabs/puppetdb/conf.d/database.ini',
             'section' => 'database',
             'setting' => 'username',
             'value'   => 'puppetdb'
             )}
      it { should contain_ini_setting('puppetdb_psdatabase_password').
        with(
             'ensure'  => 'present',
             'path'    => '/etc/puppetlabs/puppetdb/conf.d/database.ini',
             'section' => 'database',
             'setting' => 'password',
             'value'   => 'puppetdb'
             )}
      it { should contain_ini_setting('puppetdb_classname').
        with(
             'ensure'  => 'present',
             'path'    => '/etc/puppetlabs/puppetdb/conf.d/database.ini',
             'section' => 'database',
             'setting' => 'classname',
             'value'   => 'org.postgresql.Driver'
             )}
      it { should contain_ini_setting('puppetdb_subprotocol').
        with(
             'ensure'  => 'present',
             'path'    => '/etc/puppetlabs/puppetdb/conf.d/database.ini',
             'section' => 'database',
             'setting' => 'subprotocol',
             'value'   => 'postgresql'
             )}
      it { should contain_ini_setting('puppetdb_subname').
        with(
             'ensure'  => 'present',
             'path'    => '/etc/puppetlabs/puppetdb/conf.d/database.ini',
             'section' => 'database',
             'setting' => 'subname',
             'value'   => '//localhost:5432/puppetdb'
             )}
      it { should contain_ini_setting('puppetdb_gc_interval').
        with(
             'ensure'  => 'present',
             'path'    => '/etc/puppetlabs/puppetdb/conf.d/database.ini',
             'section' => 'database',
             'setting' => 'gc-interval',
             'value'   => '60'
             )}
      it { should contain_ini_setting('puppetdb_node_ttl').
        with(
             'ensure'  => 'present',
             'path'    => '/etc/puppetlabs/puppetdb/conf.d/database.ini',
             'section' => 'database',
             'setting' => 'node-ttl',
             'value'   => '0s'
             )}
      it { should contain_ini_setting('puppetdb_node_purge_ttl').
        with(
             'ensure'  => 'present',
             'path'    => '/etc/puppetlabs/puppetdb/conf.d/database.ini',
             'section' => 'database',
             'setting' => 'node-purge-ttl',
             'value'   => '0s'
             )}
      it { should contain_ini_setting('puppetdb_report_ttl').
        with(
             'ensure'  => 'present',
             'path'    => '/etc/puppetlabs/puppetdb/conf.d/database.ini',
             'section' => 'database',
             'setting' => 'report-ttl',
             'value'   => '14d'
             )}
      it { should contain_ini_setting('puppetdb_log_slow_statements').
        with(
             'ensure'  => 'present',
             'path'    => '/etc/puppetlabs/puppetdb/conf.d/database.ini',
             'section' => 'database',
             'setting' => 'log-slow-statements',
             'value'   => 10
             )}
      it { should contain_ini_setting('puppetdb_conn_max_age').
        with(
             'ensure'  => 'present',
             'path'    => '/etc/puppetlabs/puppetdb/conf.d/database.ini',
             'section' => 'database',
             'setting' => 'conn-max-age',
             'value'   => '60'
             )}
      it { should contain_ini_setting('puppetdb_conn_keep_alive').
        with(
             'ensure'  => 'present',
             'path'    => '/etc/puppetlabs/puppetdb/conf.d/database.ini',
             'section' => 'database',
             'setting' => 'conn-keep-alive',
             'value'   => '45'
             )}
      it { should contain_ini_setting('puppetdb_conn_lifetime').
        with(
             'ensure'  => 'present',
             'path'    => '/etc/puppetlabs/puppetdb/conf.d/database.ini',
             'section' => 'database',
             'setting' => 'conn-lifetime',
             'value'   => '0'
             )}
    end

    describe 'when using a legacy PuppetDB version' do
      let (:pre_condition) { 'class { "puppetdb::globals": version => "2.2.0", }' }
      it { should contain_ini_setting('puppetdb_psdatabase_username').
        with(
             'ensure'  => 'present',
             'path'    => '/etc/puppetdb/conf.d/database.ini',
             'section' => 'database',
             'setting' => 'username',
             'value'   => 'puppetdb'
             )}
      it { should contain_ini_setting('puppetdb_psdatabase_password').
        with(
             'ensure'  => 'present',
             'path'    => '/etc/puppetdb/conf.d/database.ini',
             'section' => 'database',
             'setting' => 'password',
             'value'   => 'puppetdb'
             )}
      it { should contain_ini_setting('puppetdb_classname').
        with(
             'ensure'  => 'present',
             'path'    => '/etc/puppetdb/conf.d/database.ini',
             'section' => 'database',
             'setting' => 'classname',
             'value'   => 'org.postgresql.Driver'
             )}
      it { should contain_ini_setting('puppetdb_subprotocol').
        with(
             'ensure'  => 'present',
             'path'    => '/etc/puppetdb/conf.d/database.ini',
             'section' => 'database',
             'setting' => 'subprotocol',
             'value'   => 'postgresql'
             )}
      it { should contain_ini_setting('puppetdb_subname').
        with(
             'ensure'  => 'present',
             'path'    => '/etc/puppetdb/conf.d/database.ini',
             'section' => 'database',
             'setting' => 'subname',
             'value'   => '//localhost:5432/puppetdb'
             )}
      it { should contain_ini_setting('puppetdb_gc_interval').
        with(
             'ensure'  => 'present',
             'path'    => '/etc/puppetdb/conf.d/database.ini',
             'section' => 'database',
             'setting' => 'gc-interval',
             'value'   => '60'
             )}
      it { should contain_ini_setting('puppetdb_node_ttl').
        with(
             'ensure'  => 'present',
             'path'    => '/etc/puppetdb/conf.d/database.ini',
             'section' => 'database',
             'setting' => 'node-ttl',
             'value'   => '0s'
             )}
      it { should contain_ini_setting('puppetdb_node_purge_ttl').
        with(
             'ensure'  => 'present',
             'path'    => '/etc/puppetdb/conf.d/database.ini',
             'section' => 'database',
             'setting' => 'node-purge-ttl',
             'value'   => '0s'
             )}
      it { should contain_ini_setting('puppetdb_report_ttl').
        with(
             'ensure'  => 'present',
             'path'    => '/etc/puppetdb/conf.d/database.ini',
             'section' => 'database',
             'setting' => 'report-ttl',
             'value'   => '14d'
             )}
      it { should contain_ini_setting('puppetdb_log_slow_statements').
        with(
             'ensure'  => 'present',
             'path'    => '/etc/puppetdb/conf.d/database.ini',
             'section' => 'database',
             'setting' => 'log-slow-statements',
             'value'   => 10
             )}
      it { should contain_ini_setting('puppetdb_conn_max_age').
        with(
             'ensure'  => 'present',
             'path'    => '/etc/puppetdb/conf.d/database.ini',
             'section' => 'database',
             'setting' => 'conn-max-age',
             'value'   => '60'
             )}
      it { should contain_ini_setting('puppetdb_conn_keep_alive').
        with(
             'ensure'  => 'present',
             'path'    => '/etc/puppetdb/conf.d/database.ini',
             'section' => 'database',
             'setting' => 'conn-keep-alive',
             'value'   => '45'
             )}
      it { should contain_ini_setting('puppetdb_conn_lifetime').
        with(
             'ensure'  => 'present',
             'path'    => '/etc/puppetdb/conf.d/database.ini',
             'section' => 'database',
             'setting' => 'conn-lifetime',
             'value'   => '0'
             )}
    end

    describe 'when overriding database_path for embedded' do
      let(:params) do
        {
           'database' => 'embedded',
           'database_embedded_path' => '/tmp/foo',
        }
      end
      it { should contain_ini_setting('puppetdb_subname').
        with(
             'ensure'  => 'present',
             'path'    => '/etc/puppetlabs/puppetdb/conf.d/database.ini',
             'section' => 'database',
             'setting' => 'subname',
             'value'   => 'file:/tmp/foo;hsqldb.tx=mvcc;sql.syntax_pgs=true'
             )}
    end
  end
end
