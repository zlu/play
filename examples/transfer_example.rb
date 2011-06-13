#!/usr/bin/env ruby

$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require 'rubygems'
require File.join(File.expand_path('../../lib', __FILE__), 'connfu')

Connfu.setup "usera@127.0.0.1", "1"

class TransferExample
  include Connfu

  on :offer do
    answer
    say 'please wait while we transfer your call'
    transfer('sip:usera@127.0.0.1')
    answer
    say 'wait wait welcome to connfu transfer'
  end
end

TransferExample.new
Connfu.start