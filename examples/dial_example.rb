#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'connfu'

Connfu.setup "usera@127.0.0.1", "1"

class DialExample
  include Connfu::Dsl

  dial :to => 'sip:lazyatom@213.192.59.75', :from => "sip:usera@127.0.0.1" do |c|
    c.on_answer do
      p "****Call Answered ****"
      sleep 1
      say "What is your name?"
      start_recording "file:///tmp/hello_james.mp3"
      sleep 2
      stop_recording
      hangup
    end
  end
end

Connfu.start DialExample
