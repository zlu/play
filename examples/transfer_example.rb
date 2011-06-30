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
    transfer 'sip:lazyatom@213.192.59.75', 'sip:zlu@213.192.59.75'
  end
end

Connfu.start TransferExample