#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'connfu'

Connfu.setup "usera@127.0.0.1", "1"

class TransferBusy
  include Connfu::Dsl

  on :offer do
    answer
#    result = transfer 'sip:zlu@213.192.59.75', :timeout => 15
    result = transfer 'sip:zlu@81.23.228.140', :timeout => 15
    puts "The transfer was rejected because far-end is busy" if result.busy?
  end
end

Connfu.start TransferBusy