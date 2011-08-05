#!/usr/bin/env ruby
require File.expand_path('../environment', __FILE__)

DIAL_TO = ENV['DIAL_TO']
unless DIAL_TO and DIAL_TO.split(',').length == 2
  puts "Please specify two recipients by setting DIAL_TO, e.g. DIAL_TO=foo@example.com,bar@example.com"
  exit 1
end
RECIPIENT_1, RECIPIENT_2 = DIAL_TO.split(',')

Connfu.start do
  dial :to => "sip:#{RECIPIENT_1}", :from => "sip:usera@127.0.0.1"
  dial :to => "sip:#{RECIPIENT_2}", :from => "sip:usera@127.0.0.1"

  on :outgoing_call do |c|
    c.on_answer do
      sleep 2
      record_for(5)
    end
  end
end