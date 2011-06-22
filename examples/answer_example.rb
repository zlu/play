#!/usr/bin/env ruby

$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require 'rubygems'
require File.join(File.expand_path('../../lib', __FILE__), 'connfu')

Connfu.setup "usera@127.0.0.1", "1"

class AnswerExample
  include Connfu

  on :offer do
    answer
    say('hello, this is connfu')
    say('http://www.phono.com/audio/troporocks.mp3')
  end
end

Connfu.start