#!/usr/bin/env ruby

$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require 'rubygems'
require File.join(File.expand_path('../../lib', __FILE__), 'connfu')

Connfu.setup "usera@127.0.0.1", "1"

class DialExample
  include Connfu

  current_call = dial 'sip:userb@127.0.0.1'

#  (1..10).each do
#    p Connfu.outbound_calls.values.first.state
#    sleep 5
#  end
end

Connfu.start DialExample