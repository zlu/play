#!/usr/bin/env ruby

$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require 'rubygems'
require File.join(File.expand_path('../../lib', __FILE__), 'connfu')

Connfu.setup "usera@localhost", "1"

class AnswerExample
  include Connfu

  on :offer do
    answer
    say('hello, this is connfu')
    hangup
  end
end

AnswerExample.new
Connfu.start