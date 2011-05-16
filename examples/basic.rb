#!/usr/bin/ruby

# Start as (-D for debug):
#   ./blather_ozone.rb -D 

require 'rubygems'
require 'blather/client'
require 'awesome_print'

# The user credentials want to login Ozone as
client_jid = 'usera@127.0.0.1'
client_password = '1'

class Ozone
  attr_reader :state, :call_id, :request_id
  
  def initialize(client_jid)
    @client_jid = client_jid
    
    # Use @state to manage what state our call is in
    @state = :start
    @request_id = nil
  end
  
  # call_id setter 
  def call_id=(call_id)
    @call_id = call_id
  end
  
  def answer
    # Set the state
    @state = :answered
    # Create our <iq/> stanza container
    iq_stanza = create_iq_stanza
    # Add the specific XML snippet for the say
    builder = Nokogiri::XML::Builder.with(iq_stanza) { |xml| 
      xml.answer("xmlns" => "urn:xmpp:ozone:1")
    }
    # Store the request id that Blather generated
    @request_id = iq_stanza.id
    show_sending(iq_stanza)
    iq_stanza
  end
  
  def say_audio(url)
    @state = :saying_audio
    iq_stanza = create_iq_stanza
    builder = Nokogiri::XML::Builder.with(iq_stanza) { |xml| 
      xml.say_("xmlns" => "urn:xmpp:ozone:say:1") {
        xml.audio("url" => url)
      }
    }
    @request_id = iq_stanza.id
    show_sending(iq_stanza)
    iq_stanza
  end
  
  def say_text(text)
    @state = :saying_text
    iq_stanza = create_iq_stanza
    builder = Nokogiri::XML::Builder.with(iq_stanza) { |xml| 
      xml.say_("xmlns" => "urn:xmpp:ozone:say:1") {
        xml.speak text
      }
    }
    @request_id = iq_stanza.id
    show_sending(iq_stanza)
    iq_stanza
  end
  
  def ask(prompt, choices)
    @state = :asking
    iq_stanza = create_iq_stanza
    builder = Nokogiri::XML::Builder.with(iq_stanza) { |xml| 
      xml.ask("xmlns" => "urn:xmpp:ozone:ask:1") {
        xml.prompt { xml.speak prompt }
        xml.choices("content-type" => "application/grammar+voxeo") {
          xml.text choices
        }
      }
    }
    @request_id = iq_stanza.id
    show_sending(iq_stanza)
    iq_stanza
  end
  
  def transfer(destination)
    @state = :transferred
    iq_stanza = create_iq_stanza
    builder = Nokogiri::XML::Builder.with(iq_stanza) { |xml| 
      xml.transfer("xmlns"      => "urn:xmpp:ozone:transfer:1",
                   "to"         => destination,
                   "terminator" => '#')
    }
    @request_id = iq_stanza.id
    show_sending(iq_stanza)
    iq_stanza
  end
  
  def hangup
    # Set the start so that we may now accept another call on this connection
    @state = :start
    iq_stanza = create_iq_stanza
    builder = Nokogiri::XML::Builder.with(iq_stanza) { |xml| 
      xml.hangup("xmlns" => "urn:xmpp:ozone:hangup:1")
    }
    @request_id = iq_stanza.id
    show_sending(iq_stanza)
    iq_stanza
  end
  
  private 
  
  def create_iq_stanza
    iq_stanza = Blather::Stanza::Iq.new(:set, @call_id)
    iq_stanza.from = @client_jid
    iq_stanza
  end
  
  def show_sending(iq_stanza)
    ap 'Sending to Server' + '=====>'
    ap iq_stanza
    ap '=====>'
  end
end

# Establish the connection to the Prism/XMPP server
setup client_jid, client_password

# Instantiate our Ozone object
@ozone = Ozone.new(client_jid)

# Lets us know when we are logged in
when_ready {
  ap 'Logged in!'
}

# Filters for all <iq/> messages and executes the block
iq do |m|
  ap 'inside of iq handler'
  ap 'Received from Server' + '<====='
  ap m
  ap m.class.name
  ap '<====='
  if m.attributes['id'].value != @ozone.request_id
    # Naive script for now, simply does a serial execution of a callflow
    case @ozone.state
    when :start
      @ozone.call_id = m.from.to_s

      # Acknowledge the Offer to accept the call
      m.reply!

      write_to_stream @ozone.answer
    when :answered
      #write_to_stream @ozone.say_audio("http://dl.dropbox.com/u/25511/Voxeo/troporocks.mp3")
      write_to_stream @ozone.say_text("Tropo Rocks!")
    when :saying_text
      write_to_stream @ozone.ask("What is your favorite color?", "red, green, blue")
    when :asking
      write_to_stream @ozone.transfer("sip:jose@10.0.2.11:49152")
    when :transferred
      #write_to_stream @ozone.hangup
    end
  end
end