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
    say 'please wait'

    dial_options = {
      :from => call.to[:address],
      :client_jid => Connfu.connection.jid.to_s,
      :rayo_host => Connfu.connection.jid.domain
    }
    call_1_result = send_command Connfu::Commands::Dial.new(dial_options.merge(:to => "sip:#{RECIPIENT_1}"))
    observe_events_for(call_1_result.ref_id)

    call_2_result = send_command Connfu::Commands::Dial.new(dial_options.merge(:to => "sip:#{RECIPIENT_2}"))
    observe_events_for(call_2_result.ref_id)

    answered_result = wait_for Connfu::Event::Answered
    sleep 1 # This is necessary, see https://github.com/tropo/tropo2/issues/133
    send_command Connfu::Commands::Join.new(:client_jid => client_jid, :call_jid => call_jid, :call_id => answered_result.call_id)
    
    wait_for Connfu::Event::Hangup
    @finished = true
    puts "The call was answered, and has finished"
  end
end