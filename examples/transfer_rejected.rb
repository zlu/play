#!/usr/bin/env ruby
require File.expand_path('../environment', __FILE__)

Connfu.start do
  on :offer do |call|
    answer
    result = transfer 'sip:zlu@213.192.59.75', :timeout => 15
    puts "The transfer was rejected" if result.rejected?
  end
end