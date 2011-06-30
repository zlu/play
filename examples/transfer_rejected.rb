#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'connfu'

Connfu.setup "usera@127.0.0.1", "1"

class TransferRejected
  include Connfu::Dsl

  on :offer do
    answer
    result = transfer('sip:user1@192.168.1.49', 'sip:user2@192.168.1.49', :timeout => 15)
    p result
    #puts "The transfer was rejected" if result.rejected?
  end
end

Connfu.start TransferRejected