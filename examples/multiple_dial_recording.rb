#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'connfu'

Connfu.setup "usera@127.0.0.1", "1"
#Connfu.setup "usera@46.137.85.52", "1"

class MultipleDialRecordingExample
  include Connfu::Dsl

  def update_status(status)
    File.open("/tmp/status.log", "a") { |f| f.puts "Status change: #{status}" }
  end

  dial :to => 'sip:zlu@213.192.59.75', :from => "sip:usera@127.0.0.1"
  dial :to => 'sip:openvoice@213.192.59.75', :from => "sip:usera@127.0.0.1"

  on :outgoing_call do |c|
    c.on_answer do
      update_status "This is recording for call #{c.call_id}"
      record_for(5)
    end
  end
end

Connfu.start DialExample
