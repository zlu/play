#!/usr/bin/env ruby

require 'rubygems'
require 'connfu'

jid = 'usera@127.0.0.1'
pwd = '1'

setup jid, pwd

when_ready {
  ap "Connected to Prism as #{jid}"
  Connfu::Utils.disco_items
}

iq do |di|
  ap 'Received from Server'
  ap di
  ap '<==================='
end
