source ENV['GEM_SOURCE'] || 'https://rubygems.org'

def location_for(place, fake_version = nil)
  if place =~ /^(git:[^#]*)#(.*)/
    [fake_version, { :git => $1, :branch => $2, :require => false }].compact
  elsif place =~ /^file:\/\/(.*)/
    ['>= 0', { :path => File.expand_path($1), :require => false }]
  else
    [place, { :require => false }]
  end
end

group :development, :unit_tests do
  gem 'nokogiri', '1.6.8.1',                 :require => false
  gem 'rspec-puppet', '~> 2.4',             :require => false
  gem 'fast_gettext', '1.1.0',              :require => false
  gem 'rspec-core', '3.5',                  :require => false
  gem 'puppetlabs_spec_helper', '1.1.1',    :require => false
  gem 'puppet-lint', '2.0.2',               :require => false
  gem 'metadata-json-lint',                 :require => false
  gem 'faraday',                            :require => false
  # addressable 2.5.0 pulls in public_suffix >= 2.0 requires ruby >= 2.0
  gem 'addressable', ['< 2.5.0']
    # json_pure 2.0.2 requires ruby >= 2.0 and we don't have it on Ubuntu Trusty
  gem 'json_pure', ['2.0.1']
end

group :system_tests do

  gem 'beaker-hostgenerator', '0.8.1'
  gem 'beaker' , '< 3.0.0'
  if beaker_version = ENV['BEAKER_VERSION']
    ## TODO - Remove hardcoded version as soon as BKR-885 is fixed
    ## https://tickets.puppetlabs.com/browse/BKR-885
    # gem 'beaker', *location_for(beaker_version)
  end
  if beaker_rspec_version = ENV['BEAKER_RSPEC_VERSION']
    gem 'beaker-rspec', *location_for(beaker_rspec_version)
  else
    gem 'beaker-rspec',  :require => false
  end

  gem 'serverspec', '2.37.2',    :require => false
  gem 'beaker-puppet_install_helper' ,'0.5.0', :require => false
  gem 'r10k',                               :require => false
end

if facterversion = ENV['FACTER_GEM_VERSION']
  gem 'facter', facterversion, :require => false
else
  gem 'facter', :require => false
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end

# vim:ft=ruby
