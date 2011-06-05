#!/usr/bin/env ruby

$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require 'rubygems'
require File.join(File.expand_path('../../lib', __FILE__), 'connfu')

Connfu.setup "usera@127.0.0.1", "1"

class DialExample
  include Connfu

  dial 'usera@127.0.0.1'

end

DialExample.new
Connfu.start