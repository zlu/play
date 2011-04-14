#!/usr/bin/ruby
require 'rubygems'
require 'blather/client'
require 'awesome_print'
require 'credentials'

include Credentials

module Ozone
  @client_jid = CLIENT_JID

  def self.offer
    iq = Blather::Stanza::Iq.new(:set, @client_jid, Blather::Stanza.next_id)
    Nokogiri::XML::Builder.with(iq) { |xml|
      xml.offer("xmlns"=>"urn:xmpp:ozone") {
        xml.To 'tel:+14157044517'
        xml.From 'tel:+14155551212'
      }
    }
    iq
  end
end

setup SERVER_JID, SERVER_PWD
when_ready {
  write_to_stream Ozone::offer
}

iq do |m|
  ap 'FromClient' + '*'*10
  ap m
  ap 'FromClient' + '*'*10
end
