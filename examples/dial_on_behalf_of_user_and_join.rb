#!/usr/bin/env ruby
require File.expand_path('../environment', __FILE__)

require_two_recipients!

Connfu.start do
  on :ready do
    caller = "sip:#{RECIPIENTS.first}"
    recipient = "sip:#{RECIPIENTS.last}"

    dial :to => caller, :from => "sip:usera@127.0.0.1" do |c|
      c.on_ringing do
        puts "OK, ringing"
      end

      c.on_answer do
        puts "OK, now dialing the outbound leg"
        command_options = {
          :call_jid => call_jid,
          :client_jid => client_jid,
          :dial_to => recipient,
          :dial_from => "sip:usera@127.0.0.1",
          :call_id => call_id
        }
        result = send_command Connfu::Commands::NestedJoin.new(command_options)
        puts "waiting for hangup"
        wait_for Connfu::Event::Hangup
      end
    end
  end
end