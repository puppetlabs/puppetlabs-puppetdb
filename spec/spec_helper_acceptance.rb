require 'beaker-rspec'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'

hosts.each do |host|
  if host['platform'] =~ %r{debian}
    on host, 'echo \'export PATH=/var/lib/gems/1.8/bin/:${PATH}\' >> ~/.bashrc'
  end
  # install_puppet
  if host['platform'] =~ %r{el-(5|6|7)}
    relver = Regexp.last_match(1)
    on host, "rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-pc1-el-#{relver}.noarch.rpm"
    on host, 'yum install -y puppetserver'
  elsif host['platform'] =~ %r{fedora-(\d+)}
    relver = Regexp.last_match(1)
    on host, "rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-pc1-fedora-#{relver}.noarch.rpm"
    on host, 'yum install -y puppetserver'
  elsif host['platform'] =~ %r{(ubuntu|debian)}
    unless host.check_for_package 'curl'
      on host, 'apt-get install -y curl'
    end
    on host, 'apt-get install apt-transport-https --assume-yes'
    on host, 'curl -O http://apt.puppetlabs.com/puppetlabs-release-pc1-$(lsb_release -c -s).deb'
    on host, 'dpkg -i puppetlabs-release-pc1-$(lsb_release -c -s).deb'
    on host, 'apt-get -y -m update'
    on host, 'apt-get install -y puppetserver'
  else
    raise "install_puppet() called for unsupported platform '#{host['platform']}' on '#{host.name}'"
  end
end

run_puppet_install_helper unless ENV['BEAKER_provision'] == 'no'
install_ca_certs unless ENV['PUPPET_INSTALL_TYPE'] =~ %r{pe}i
install_module_on(hosts)
install_module_dependencies_on(hosts)

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation
  hosts.each do |host|
    if host[:platform] =~ %r{el-7-x86_64} && host[:hypervisor] =~ %r{docker}
      on(host, "sed -i '/nodocs/d' /etc/yum.conf")
    end
  end
end
