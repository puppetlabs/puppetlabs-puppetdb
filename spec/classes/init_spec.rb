require 'spec_helper'
describe 'puppetdb' do

  ttl_args = ['node_ttl','node_purge_ttl','report_ttl']

  context 'on a supported platform' do
    let(:facts) { { :osfamily                 => 'RedHat',
                    :postgres_default_version => '9.1',
                    :concat_basedir           => '/var/lib/puppet/concat',
                } }

    describe 'when using default values for puppetdb class' do
      it {
        should contain_class('puppetdb')
      }
    end

    ttl_args.each do |ttl_arg|
      describe "when using 0 for #{ttl_arg} puppetdb class" do
        it {
          should contain_class('puppetdb')
        }
        describe "when using a capitalized time signifier for #{ttl_arg} for puppetdb class" do
          it {
            should contain_class('puppetdb')
          }
        end
      end
    end
  end

  context 'with invalid arguments on a supported platform' do
    let(:facts) { { :osfamily                 => 'RedHat',
                    :postgres_default_version => '9.1',
                    :concat_basedir           => '/var/lib/puppet/concat',
                } }
    ttl_args.each do |ttl_arg|
      let(:params) { { ttl_arg => 'invalid_value' } }
      describe "when using a value that does not match the validation regex for #{ttl_arg} puppetdb class" do
        it {
          expect {
            should contain_class('puppetdb')
          }.to raise_error(Puppet::Error)
        }
      end
    end
  end
end
