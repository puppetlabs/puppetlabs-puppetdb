require 'spec_helper_system'

describe 'basic tests:' do
  it 'make sure we have copied the module across' do
    # No point diagnosing any more if the module wasn't copied properly
    shell("ls /etc/puppet/modules/puppetdb") do |r|
      r.exit_code.should == 0
      r.stdout.should =~ /Modulefile/
      r.stderr.should == ''
    end
  end

  it 'make sure a puppet agent has ran' do
    puppet_agent do |r|
      r.stderr.should == ''
      r.exit_code.should == 0
    end
  end

  describe 'single node setup' do
    let(:pp) do
      pp = <<-EOS
# Single node setup
class { 'puppetdb': }
class { 'puppetdb::master::config': }
      EOS
    end

    it 'make sure it runs without error' do
      shell('puppet module install puppetlabs/stdlib --version ">= 2.2.0"')
      shell('puppet module install puppetlabs/postgresql --version ">= 3.1.0 <4.0.0"')
      shell('puppet module install puppetlabs/inifile --version "1.x"')

      puppet_apply(pp) do |r|
        r.exit_code.should_not eq(1)
        r.refresh
        r.exit_code.should == 0
      end
    end
  end

  describe 'enabling report processor' do
    let(:pp) do
      pp = <<-EOS
class { 'puppetdb::master::config':
  manage_report_processor => true,
  enable_reports => true
}
      EOS
    end

    it 'should add the puppetdb report processor to puppet.conf' do
      puppet_apply(pp) do |r|
        r.exit_code.should_not eq(1)
        r.refresh
        r.exit_code.should == 0
      end

      shell("cat /etc/puppet/puppet.conf") do |r|
        r[:stdout].should =~ /^reports\s*=\s*([^,]+,)*puppetdb(,[^,]+)*$/
      end
    end

  end

end
