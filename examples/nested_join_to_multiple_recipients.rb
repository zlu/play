#!/usr/bin/env ruby
require File.expand_path('../environment', __FILE__)

Connfu.io_log = Connfu::Logging::IOLogger.new("/tmp/xmpp.log")

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
    result = send_command Connfu::Commands::NestedJoin.new(command_options.merge(:dial_to => "sip:chrisroos@iptel.org"))
    observe_events_for(result.ref_id)

    result2 = send_command Connfu::Commands::NestedJoin.new(command_options.merge(:dial_to => "sip:lazyatom@iptel.org"))
    observe_events_for(result2.ref_id)

    logger.debug "Monitoring events for #{observed_call_ids.inspect}"

    wait_for Connfu::Event::Answered
    logger.debug "The far end has answered"

    wait_for Connfu::Event::Hangup
    @finished = true
    logger.debug "The far end hungup"
  end
end
