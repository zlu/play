#!/usr/bin/env ruby
require File.expand_path('../environment', __FILE__)

Connfu.start do
  on :offer do |call|
    answer
    say 'please wait'

    result = send_command Connfu::Commands::Dial.new(:to => "sip:jasoncale@iptel.org", :from => call.to[:address])
    observe_events_for(result.ref_id)

    # result_2 = send_command Connfu::Commands::Dial.new(:to => "sip:jasentonic@iptel.org", :from => call.to[:address])
    # observe_events_for(result_2.ref_id)

    wait_for Connfu::Event::Answered
    sleep 1
    send_command Connfu::Commands::Join.new(:client_jid => client_jid, :to => "#{call_id}@127.0.0.1", :call_id => result.ref_id)

    # command_options = {
    #   :to => call_jid,
    #   :client_jid => client_jid,
    #   :dial_to => "sip:someone@iptel.org",
    #   :dial_from => call.to[:address],
    #   :call_id => call_id
    # }
    #
    # result = send_command Connfu::Commands::NestedJoin.new(command_options)
    # observe_events_for(result.ref_id)

    # presence_iq = wait_for Connfu::Event::Joined
    # observe_events_for(presence_iq.joined_call_id)

    # wait_for Connfu::Event::Answered

    wait_for Connfu::Event::Hangup
    @finished = true
    puts "The call was answered, and has finished"
  end
end