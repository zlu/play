#!/usr/bin/env ruby
require File.expand_path('../environment', __FILE__)

exit_with_usage_message unless DIAL_TO = ENV['DIAL_TO']

class DialAndHangupOnRingingExample
  include Connfu::Dsl

  def update_status(status)
    File.open("/tmp/status.log", "a") { |f| f.puts "Status change: #{status}" }
  end

  dial :to => "sip:#{DIAL_TO}", :from => "sip:usera@127.0.0.1"

  on :outgoing_call do |c|
    c.on_ringing do
      update_status "The phone is ringing but about to hangup!"
      hangup
    end
  end
end

Connfu.start DialAndHangupOnRingingExample
