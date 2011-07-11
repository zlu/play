#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'connfu'

Connfu.setup "usera@127.0.0.1", "1"

class RecordingExample
  include Connfu::Dsl

  on :offer do
    answer
    start_recording("file://tmp/recording.mp3")

    sleep 5

    stop_recording

    sleep 5
    hangup
  end
end

Connfu.start RecordingExample