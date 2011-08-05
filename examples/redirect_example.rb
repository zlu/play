#!/usr/bin/env ruby
require File.expand_path('../environment', __FILE__)

exit_with_usage_message unless DIAL_TO = ENV['DIAL_TO']

Connfu.start do
  on :offer do |call|
    redirect("sip:#{DIAL_TO}")
  end
end