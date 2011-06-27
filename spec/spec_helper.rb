require 'rubygems'
require 'rspec'
require File.expand_path("../../lib/connfu", __FILE__)

RSpec.configure do |config|
  config.include RSpec::Matchers
  config.mock_with :mocha
end

l.level = Logger::WARN

class MyTestClass
  include Connfu
end

def create_stanza(presence_xml)
  doc = Nokogiri::XML.parse presence_xml
  Blather::Stanza::Presence.import(doc.root)
end

def run_fake_event_loop(*events, &block)
  while event = events.shift do
    Connfu::EventProcessor.handle_event(event)
  end
end

RSpec::Matchers.define :be_stanzas do |expected_stanzas|
  match do |actual|
    actual.map { |x| x.to_s.gsub(/\n\s*/, "\n") } == expected_stanzas.map { |x| x.to_s.gsub(/\n\s*/, "\n") }
  end
end

class TestConnection
  attr_reader :commands

  def initialize
    @commands = []
  end
  def send_command(command)
    @commands << command
  end
end

def result_iq
  "<iq type='result' id='blather000b' from='localhost' to='usera@localhost/voxeo'/>"
end

def offer_presence(from='4a3fe31a-0c2a-4a9a-ae98-f5b8afb55708@127.0.0.1', to='usera@127.0.0.1/voxeo')
  "<presence from='#{from}' to='#{to}'>
    <offer xmlns='urn:xmpp:ozone:1' to='sip:usera@127.0.0.1:5060' from='sip:16508983130@127.0.0.1'>
      <header name='Max-Forwards' value='70'/>
      <header name='Content-Length' value='422'/>
      <header name='Contact' value='&lt;sip:16508983130@127.0.0.1:21702&gt;'/>
      <header name='Supported' value='replaces'/>
      <header name='Allow' value='INVITE'/>
      <header name='To' value='&lt;sip:usera@127.0.0.1:5060&gt;'/>
      <header name='CSeq' value='1 INVITE'/>
      <header name='User-Agent' value='Bria 3 release 3.2 stamp 61503'/>
      <header name='Via' value='SIP/2.0/UDP 127.0.0.1:21702;branch=z9hG4bK-d8754z-ab966854f39bb612-1---d8754z-;rport=21702'/>
      <header name='Call-ID' value='MGRkMWJiOTVmM2ViMGM4NWNiYmFhZDk5NGMwMDcwOTE.'/>
      <header name='Content-Type' value='application/sdp'/>
      <header name='From' value='&lt;sip:16508983130@127.0.0.1&gt;;tag=34ccaa4d'/>
    </offer>
  </presence>"
end

def answer_iq
  %{<iq type="set" to="9c011b43-b9be-4322-9adf-3d18e3af2f1b@127.0.0.1" id="blather000a" from="usera@127.0.0.1/voxeo">
    <answer xmlns="urn:xmpp:ozone:1"/>
  </iq>}
end

def say_complete_success
  "<presence from='7bc6c7d5-1428-421d-bb40-22f58cdcd2ec@127.0.0.1/a1b45d70-6df2-4460-b172-4bd077e8966d' to='usera@127.0.0.1/voxeo'>
    <complete xmlns='urn:xmpp:ozone:ext:1'>
      <success xmlns='urn:xmpp:ozone:say:complete:1'/>
    </complete>
  </presence>"
end