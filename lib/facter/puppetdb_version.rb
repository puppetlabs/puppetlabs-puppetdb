Facter.add(:puppetdb_version) do
  confine { Facter::Util::Resolution.which('puppetdb') }

  setcode do
    command = 'puppetdb --version'
    splitter = ':'
    postion = 'last'

    if Facter.value(:os)['family'] == 'Debian'
      package_maintainer = Facter::Core::Execution.execute('apt-cache show puppetdb | grep "Maintainer:" | head -1')

      unless package_maintainer.include? 'Puppet Labs'
        command = 'dpkg-query --showformat=\'${Version}\' --show puppetdb'
        splitter = '-'
        postion = 'first'
      end
    end

    begin
      output = Facter::Core::Execution.execute(command)
      output.split(splitter).send(postion).strip
    rescue Facter::Core::Execution::ExecutionFailure
      nil
    end
  end
end
