#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'connfu'

Connfu.setup "usera@127.0.0.1", "1"

class TransferExample
  include Connfu::Dsl

  on :offer do
    answer
    say 'please wait while we transfer your call'
    transfer  'sip:zlu@iptel.org', 'sip:zhao@sip2sip.info', :timeout => 5, :mode => :round_robin
  end
end

Connfu.start TransferExample