#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'connfu'

Connfu.setup "usera@127.0.0.1", "1"

class DialExample
  include Connfu::Dsl

  dial :to => 'sip:kalv@213.192.59.75', :from => "sip:usera@127.0.0.1"

  on :answer do
    p "****Call Answered ****"
    sleep 1
    hangup
  end

end

Connfu.start DialExample
