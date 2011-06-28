#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'connfu'

Connfu.setup "usera@127.0.0.1", "1"

class DialExample
  include Connfu::Dsl

  current_call = dial 'sip:userb@127.0.0.1'

#  (1..10).each do
#    p Connfu.outbound_calls.values.first.state
#    sleep 5
#  end
end

Connfu.start DialExample