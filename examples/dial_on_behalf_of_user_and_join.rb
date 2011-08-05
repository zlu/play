#!/usr/bin/env ruby
require File.expand_path('../environment', __FILE__)

class DialOnBehalfOfUserAndJoin
  include Connfu::Dsl

  caller = "sip:lazyatom@iptel.org"
  recipient = "sip:chrisroos@iptel.org"

  dial :to => caller, :from => "sip:usera@127.0.0.1"

  on :outgoing_call do |c|
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
      sleep 1
      result = send_command Connfu::Commands::NestedJoin.new(command_options)
      observe_events_for(result.ref_id)
      puts "waiting for hangup"
      wait_for Connfu::Event::Hangup
    end
  end
end

Connfu.start DialOnBehalfOfUserAndJoin
