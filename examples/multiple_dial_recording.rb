#!/usr/bin/env ruby
require File.expand_path('../environment', __FILE__)

Connfu.start do
  dial :to => 'sip:zlu@213.192.59.75', :from => "sip:usera@127.0.0.1"
  dial :to => 'sip:openvoice@213.192.59.75', :from => "sip:usera@127.0.0.1"

  on :outgoing_call do |c|
    c.on_answer do
      sleep 2
      record_for(5)
    end
  end
end