#!/usr/bin/env ruby

require 'rubygems'
require 'connfu'

jid = 'usera@127.0.0.1'
pwd = '1'

setup jid, pwd

when_ready {
  l.info "Connected to Prism as #{jid}"
  Connfu::Utils.disco_items
}

iq do |di|
  l.info 'Received from Server'
  l.info di
  l.info '<==================='
end
