require 'rubygems'
require 'rspec'
require File.expand_path("../../lib/connfu", __FILE__)

RSpec.configure do |config|
  config.include RSpec::Matchers
  config.mock_with :rspec
end
