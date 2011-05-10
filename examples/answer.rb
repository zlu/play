#!/usr/bin/env ruby

$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require 'rubygems'
require File.join(File.expand_path('../../lib', __FILE__), 'connfu')

setup "usera@127.0.0.1", "1"

when_ready {
  ap "connected to server"
}

iq do |m|
  write_to_stream Connfu::Commands.answer('foo')
end

