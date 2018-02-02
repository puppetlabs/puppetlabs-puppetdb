require 'spec_helper'

describe 'puppetdb::cli', :type => :class do
  context 'on a supported platform' do
    let(:facts) do
      {
        :osfamily => 'Debian',
        :operatingsystem => 'Debian',
        :operatingsystemrelease => '6.0',
        :kernel => 'Linux',
        :concat_basedir => '/var/lib/puppet/concat',
        :lsbdistid => 'Debian',
        :lsbdistcodename => 'foo',
        :id => 'root',
        :path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        :selinux => false,
        :iptables_persistent_version => '0.5.7',
      }
    end

    describe 'when using default values for puppetdb class' do
      it { should contain_class('puppetdb::cli') }
      it { should contain_package('puppet-client-tools') }
      it { should contain_file('/etc/puppetlabs/client-tools/puppetdb.conf') }
    end
  end
end
