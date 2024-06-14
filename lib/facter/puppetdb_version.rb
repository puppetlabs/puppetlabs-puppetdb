Facter.add(:puppetdb_version) do
  confine { Facter::Util::Resolution.which('puppetdb') }

  setcode do
    require 'open3'

    # check if os is debian/ubuntu and the package is not from puppetlabs
    if Facter.value(:osfamily) == 'Debian'
      package_maintainer = Facter::Core::Execution.execute('apt-cache show puppetdb | grep "Maintainer:" | head -1')
      unless package_maintainer.include? 'Puppet Labs'
        output, status = Open3.capture2('dpkg-query --showformat=\'${Version}\' --show puppetdb')
        if status.success?
          output.strip.split('-').first
        else
          nil
        end
      end
    else
      output, status = Open3.capture2('puppetdb --version')
      if status.success?
        output.split(':').last.strip
      else
        nil
      end
    end
  end
end
