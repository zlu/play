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
    unless transfer('sip:userb@127.0.0.1', :timeout => 2.seconds)
      say "sorry about that but tom is drinking afternoon tea"
    end
  end
end

Connfu.start TransferExample