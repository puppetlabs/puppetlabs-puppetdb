require 'facter'

describe 'puppetdb_version' do
  before(:each) do
    Facter.clear
  end

  context 'when puppetdb is available' do
    before(:each) do
      allow(Facter::Util::Resolution).to receive(:which).with('puppetdb').and_return('/usr/bin/puppetdb')
    end

    context 'on a default system' do
      it 'returns the correct version from puppetdb --version' do
        expect(Facter::Core::Execution).to receive(:execute)
          .with('puppetdb --version')
          .and_return('puppetdb version: 7.19.0')

        expect(Facter.fact(:puppetdb_version).value).to eq('7.19.0')
      end

      it 'returns nil if the command execution fails' do
        allow(Facter::Core::Execution).to receive(:execute).with('puppetdb --version').and_raise(Facter::Core::Execution::ExecutionFailure)

        expect(Facter.fact(:puppetdb_version).value).to be_nil
      end
    end
  end

  context 'when puppetdb is not available' do
    before(:each) do
      allow(Facter::Util::Resolution).to receive(:which).with('puppetdb').and_return(nil)
    end

    it 'returns nil' do
      expect(Facter.fact(:puppetdb_version).value).to be_nil
    end
  end
end
