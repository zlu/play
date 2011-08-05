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
    say("transferring")
    transfer_using_join "sip:#{RECIPIENT_1}", "sip:#{RECIPIENT_2}"
    puts "Joined call has ended"
  end
end
