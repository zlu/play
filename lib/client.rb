#!/usr/bin/ruby
require 'rubygems'
require 'blather/client'
require 'awesome_print'
require 'credentials'

module Connfu
  class Client
    include Credentials

    def initialize
      Blather::Client.setup CLIENT_JID, CLIENT_PWD
    end

    when_ready {
      ap 'Logged in!'
    }

# Echo back what was said
    iq do |m|
      ap 'FromServer' + '*'*10
      ap m
      ap 'FromServer' + '*'*10
      write_to_stream m.reply
    end
  end
end