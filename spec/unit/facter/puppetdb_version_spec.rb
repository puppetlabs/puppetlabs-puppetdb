require 'facter'

describe 'puppetdb_version' do
  before(:each) do
    Facter.clear
  end

  context 'when puppetdb is available' do
    before do
      allow(Facter::Util::Resolution).to receive(:which).with('puppetdb').and_return('/usr/bin/puppetdb')
    end

    context 'on a Debian-based system' do
      before do
        allow(Facter).to receive(:value).with(:os).and_return({ 'family' => 'Debian' })
      end

      context 'when Puppet Labs is the maintainer' do
        before do
          allow(Facter::Core::Execution).to receive(:execute)
            .with('apt-cache show puppetdb | grep "Maintainer:" | head -1')
            .and_return('Maintainer: Puppet Labs')
        end

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

      context 'when Puppet Labs is not the maintainer' do
        before do
          allow(Facter::Core::Execution).to receive(:execute)
            .with('apt-cache show puppetdb | grep "Maintainer:" | head -1')
            .and_return('Maintainer: Other Maintainer')
        end

        it 'returns the correct version from dpkg-query' do
          expect(Facter::Core::Execution).to receive(:execute)
            .with("dpkg-query --showformat='${Version}' --show puppetdb")
            .and_return('7.9.0-1ubuntu1')

          expect(Facter.fact(:puppetdb_version).value).to eq('7.9.0')
        end

        it 'returns nil if the command execution fails' do
          allow(Facter::Core::Execution).to receive(:execute).with("dpkg-query --showformat='${Version}' --show puppetdb").and_raise(Facter::Core::Execution::ExecutionFailure)

          expect(Facter.fact(:puppetdb_version).value).to be_nil
        end
      end
    end

    context 'on a non-Debian-based system' do
      before do
        allow(Facter).to receive(:value).with(:os).and_return({ 'family' => 'RedHat' })
      end

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
    before do
      allow(Facter::Util::Resolution).to receive(:which).with('puppetdb').and_return(nil)
    end

    it 'returns nil' do
      expect(Facter.fact(:puppetdb_version).value).to be_nil
    end
  end
end
