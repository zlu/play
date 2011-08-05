#!/usr/bin/env ruby
require File.expand_path('../environment', __FILE__)

DIAL_TO = ENV['DIAL_TO']
unless DIAL_TO and DIAL_TO.split(',').length == 2
  puts "Please specify two recipients by setting DIAL_TO, e.g. DIAL_TO=foo@example.com,bar@example.com"
  exit 1
end
RECIPIENT_1, RECIPIENT_2 = DIAL_TO.split(',')

Connfu.start do
  on :offer do |call|
    answer
    say 'please wait while we join'

    command_options = {
      :call_jid => call_jid,
      :client_jid => client_jid,
      :dial_from => call.to[:address],
      :call_id => call_id
    }
    result = send_command Connfu::Commands::NestedJoin.new(command_options.merge(:dial_to => "sip:#{RECIPIENT_1}"))
    observe_events_for(result.ref_id)

    result2 = send_command Connfu::Commands::NestedJoin.new(command_options.merge(:dial_to => "sip:#{RECIPIENT_2}"))
    observe_events_for(result2.ref_id)

    logger.debug "Monitoring events for #{observed_call_ids.inspect}"

    wait_for Connfu::Event::Answered
    logger.debug "The far end has answered"

    wait_for Connfu::Event::Hangup
    @finished = true
    logger.debug "The far end hungup"
  end
end
