#!/usr/bin/env ruby

$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require 'rubygems'
require File.join(File.expand_path('../../lib', __FILE__), 'connfu')

Connfu.setup "userb@127.0.0.1", "1"

class DialExampleHelper
  include Connfu

  on :offer do
    answer
  end
end

Connfu.start