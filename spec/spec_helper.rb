require 'rspec'
p __FILE__
p File.expand_path("../../lib/client", __FILE__)
require File.expand_path("../../lib/client", __FILE__)

RSpec.configure do |config|
  config.include RSpec::Matchers
  config.mock_with :rspec
end
