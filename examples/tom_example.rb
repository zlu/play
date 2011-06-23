#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
#require 'connfu'

#Connfu.setup "usera@127.0.0.1", "1"

module Connfu
  
  def on(arg, &block)
    yield
  end
  
  def say(string)
    puts "sending event SAY<#{string}>"
    Thread.new do
      sleep(1)
      $events << {:say_complete}
    end
  end
  
  def ask_for_number_from_keypad(arg, &block)
    when_ready do
      yield
    end
  end

  def when_ready(&block)
    until @ready
      sleep(0.5)
    end
  end

  def self.included(base)
    base.extend(self)
  end

  def self.process(event)
    
  end

  def self.start
    Thread.new do
      loop do
        if event = $events.shift
          Connfu.process(event)
        end
        sleep(1)
      end
    end
  end
end


class ThinkOfANumber
  include Connfu

  on :offer do
    number = rand(10)
    say "I'm thinking of a number between 1 and 10"
    while ask_for_number_from_keypad(0..10) != number
      say "Sorry, guess again"
    end
    say "Congratulations"
  end
end

$events = []

Connfu.start