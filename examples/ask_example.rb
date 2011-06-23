#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'connfu'

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