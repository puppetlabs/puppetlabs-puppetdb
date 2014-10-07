source ENV['GEM_SOURCE'] || "https://rubygems.org"

group :development, :test do
  gem 'rake'
  gem 'puppetlabs_spec_helper', :require => false
  gem 'beaker',                 :require => false
  gem 'beaker-rspec',           :require => false
  gem 'serverspec',             :require => false
  gem 'rspec-puppet', '~> 1.0'
  gem 'puppet-lint',  '~> 1.1'
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end
