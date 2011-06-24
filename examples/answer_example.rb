#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'connfu'

Connfu.setup "usera@127.0.0.1", "1"

class AnswerExample
  include Connfu::Dsl

  on :offer do
    answer
    say('hello, this is a much longer line of text that I hope will some a short while to read')
    say('http://www.phono.com/audio/troporocks.mp3')
  end
end

Connfu.start AnswerExample
