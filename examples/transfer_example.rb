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
    transfer(['sip:usera@127.0.0.1', 'sip:userb@127.0.0.1'])
  end
end

Connfu.start TransferExample