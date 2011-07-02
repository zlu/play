#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'connfu'

Connfu.setup "usera@127.0.0.1", "1"
#Connfu.setup "usera@ec2-79-125-61-218.eu-west-1.compute.amazonaws.com", "1"

class TransferExample
  include Connfu::Dsl

  on :offer do
    answer
    say 'please wait while we transfer your call'
    result = transfer 'sip:zlu@213.192.59.75', 'sip:lazyatom@213.192.59.75'
    puts "The call was answered, and has finished" if result.answered?
  end
end

Connfu.start TransferExample