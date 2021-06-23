require 'beaker-puppet'
require 'beaker-pe'
require 'spec_helper_acceptance'

describe 'basic tests:' do
  it 'make sure we have copied the module across' do
    # No point diagnosing any more if the module wasn't copied properly
    shell('ls /etc/puppetlabs/code/modules/puppetdb') do |r|
      r.exit_code.should be_zero
      r.stdout.should =~ %r{metadata\.json}
      r.stderr.should == ''
    end
  end

  describe 'single node setup' do
    pp = <<-EOS
      # Single node setup
      class { 'puppetdb': disable_ssl => true, } ->
      class { 'puppetdb::master::config': puppetdb_port => '8080', puppetdb_server => 'localhost' }
    EOS

    it 'make sure it runs without error' do
      apply_manifest(pp, catch_errors: true)
      apply_manifest(pp, catch_changes: true)
    end
  end

  describe 'single node with ssl' do
    ssl_config = <<-EOS
      class { 'puppetdb': postgresql_ssl_on => true,
               database_listen_address => '0.0.0.0',
               database_host => $facts['fqdn'],}
    EOS

    it 'make sure it runs without error' do
      apply_manifest(ssl_config, catch_errors: true)
      apply_manifest(ssl_config, catch_changes: true)
    end

    change_password = <<-EOS
      ini_setting { "puppetdb password":
        ensure  => present,
        path    => '/etc/puppetlabs/puppetdb/conf.d/database.ini',
        section => 'database',
        setting => 'password',
        value   => 'random_password',
        notify  => Service[puppetdb]
      }

      service { 'puppetdb':
        ensure => 'running',
      }
    EOS
    it 'make sure it starts with wrong password' do
      apply_manifest(change_password, catch_errors: true)
      apply_manifest(change_password, catch_changes: true)
    end
  end

  describe 'enabling report processor' do
    pp = <<-EOS
      class { 'puppetdb': disable_ssl => true, } ->
      class { 'puppetdb::master::config':
        puppetdb_port => '8080',
        manage_report_processor => true,
        enable_reports => true,
        puppetdb_server => 'localhost'
      }
    EOS

    it 'adds the puppetdb report processor to puppet.conf' do
      apply_manifest(pp, catch_errors: true)
      apply_manifest(pp, catch_changes: true)

      shell('cat /etc/puppetlabs/puppet/puppet.conf') do |r|
        expect(r.stdout).to match(%r{^reports\s*=\s*([^,]+,)*puppetdb(,[^,]+)*$})
      end
    end
  end

  describe 'read only user' do
    pp = <<-EOS
      class { 'puppetdb': disable_ssl => true, } ->
      class { 'puppetdb::master::config':
        puppetdb_port => '8080',
        puppetdb_server => 'localhost'
      }
    EOS

    it 'can not create tables' do
      apply_manifest(pp, catch_errors: true)
      apply_manifest(pp, catch_changes: true)

      shell('psql "postgresql://puppetdb-read:puppetdb-read@localhost/puppetdb" -c "create table tables(id int)" || true') do |r|
        expect(r.stderr).to match(%r{^ERROR:  permission denied for schema public.*})
      end
    end
  end
end
