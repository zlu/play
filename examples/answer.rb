#!/usr/bin/env ruby

$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require 'rubygems'
require 'blather/client/client'

require File.join(File.expand_path('../../lib', __FILE__), 'connfu')

connection = Connfu.setup "usera@127.0.0.1", "1"
connection.register_handler :ready, lambda {p 'Connected to the server'}
connection.register_handler :iq do |foo|
  p 'inside of iq'
  ap foo
  Connfu::Commands.answer(connection, foo.from.to_s)
end

EM.run{connection.run}
