#!/usr/bin/env ruby

$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require 'rubygems'
require File.join(File.expand_path('../../lib', __FILE__), 'connfu')

Connfu.setup "usera@127.0.0.1", "1"

class AskExample
  include Connfu

  on :offer do
    answer
    ask('please enter your four digit pin') do |result|
      say 'your input is ' + result
    end
  end
end

AskExample.new
Connfu.start