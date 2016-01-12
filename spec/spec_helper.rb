require 'puppetlabs_spec_helper/module_spec_helper'

RSpec.configure do |c|
  c.alias_it_should_behave_like_to :it_configures, 'configures'
  c.alias_it_should_behave_like_to :it_raises, 'raises'
  c.before :each do
    @default_facts = { :os_service_default => '<SERVICE DEFAULT>' }
  end
  c.mock_with :rspec do |mock_c|
    mock_c = :expect
  end
end

at_exit { RSpec::Puppet::Coverage.report! }
