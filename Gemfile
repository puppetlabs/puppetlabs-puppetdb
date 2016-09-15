source ENV['GEM_SOURCE'] || "https://rubygems.org"

group :development, :test do
  # Pinning `rake` because `v11` doesn't support Ruby 1.8.7
  gem 'rake', '10.5.0'
  gem 'puppetlabs_spec_helper', :require => false
  # Pinning due to bug in newer rspec with Ruby 1.8.7
  gem 'rspec-core', '3.1.7'
  gem 'rspec-puppet', '~> 2.0'
  gem 'puppet-lint',  '~> 1.1'
  gem 'metadata-json-lint'
  gem 'json_pure', '~> 1.8'
end

group :system_tests do
  gem 'beaker',                :require => false
  gem 'beaker-rspec',          :require => false
  gem 'serverspec',            :require => false
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end
