require 'spec_helper'

describe 'puppetdb', :type => :class do
  ttl_args = ['node_ttl','node_purge_ttl','report_ttl']

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({
          :selinux => false
        })
      end

      describe 'when using default values for puppetdb class' do
        it { should contain_class('puppetdb') }
        it { should contain_class('puppetdb::server') }
        it { should contain_class('puppetdb::database::postgresql') }
      end
    end
  end

  context 'with invalid arguments on a supported platform' do
    let(:facts) do
      {
        :osfamily => 'RedHat',
        :operatingsystem => 'Debian',
        :puppetversion => Puppet.version,
        :operatingsystemrelease => '6.0',
        :kernel => 'Linux',
        :concat_basedir => '/var/lib/puppet/concat',
        :selinux => true,
        :iptables_persistent_version => '0.5.7',
      }
    end
    ttl_args.each do |ttl_arg|
      let(:params) do
        {
          ttl_arg => 'invalid_value'
        }
      end
      it "when using a value that does not match the validation regex for #{ttl_arg} puppetdb class" do
        expect { should contain_class('puppetdb') }.to raise_error(Puppet::Error)
      end
    end
  end
end
