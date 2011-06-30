#!/usr/bin/env ruby

$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require 'rubygems'
require File.join(File.expand_path('../../lib', __FILE__), 'connfu')

Connfu.setup "usera@127.0.0.1", "1"

class TransferExample
  include Connfu::Dsl

  on :offer do
    answer
    say 'please wait while we transfer your call'
    transfer 'sip:lazyatom@213.192.59.75', 'sip:zlu@213.192.59.75', :timeout => 5, :mode => :round_robin
  end
end

Connfu.start TransferExample