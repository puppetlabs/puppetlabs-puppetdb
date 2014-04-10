require 'spec_helper'

describe 'puppetdb::master::config', :type => :class do

  let(:facts) do
    {
      :osfamily => 'Debian',
      :operatingsystem => 'Debian',
      :operatingsystemrelease => '6.0',
      :kernel => 'Linux',
      :concat_basedir => '/var/lib/puppet/concat',
    }
  end

  context 'when using default values' do
    it { should compile.with_all_deps }
  end

end
