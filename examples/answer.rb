#!/usr/bin/env ruby

$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require 'rubygems'

require File.join(File.expand_path('../../lib', __FILE__), 'connfu')

connection = Connfu.setup "usera@127.0.0.1", "1"

class Answer
  include Connfu

  def initialize(connection)
    @connection = connection
  end

  on :offer do |connection|
    Connfu::Commands.answer(connection, "abc")
  end
end

Answer.new(connection)

Connfu.start(connection)