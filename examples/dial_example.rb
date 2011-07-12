#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'connfu'

Connfu.setup "usera@127.0.0.1", "1"

class DialExample
  include Connfu::Dsl

  def update_status(status)
    File.open("/tmp/status.log", "a") { |f| f.puts "Status change: #{status}" }
  end

  dial :to => 'sip:lazyatom@213.192.59.75', :from => "sip:usera@127.0.0.1" do |c|
    c.on_ringing do
      update_status "The phone is ringing!"
    end
    c.on_answer do
      update_status "The phone was answered!"

      say "Though I am but a robot, my love for you is real."
      hangup
    end
  end
end

Connfu.start DialExample
