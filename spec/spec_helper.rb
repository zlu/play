require 'bundler/setup'
require 'rspec'
require 'connfu'

RSpec.configure do |config|
  config.include RSpec::Matchers
end

l.level = Logger::WARN

class MyTestClass
  include Connfu
end

def create_stanza(presence_xml)
  doc = Nokogiri::XML.parse presence_xml
  Blather::Stanza::Presence.import(doc.root)
end

def create_iq(iq_xml)
  doc = Nokogiri::XML.parse iq_xml
  Blather::Stanza::Iq.import(doc.root)
end

RSpec::Matchers.define :be_stanzas do |expected_stanzas|
  match do |actual|
    actual.map { |x| x.to_s.gsub(/\n\s*/, "\n") } == expected_stanzas.map { |x| x.to_s.gsub(/\n\s*/, "\n") }
  end
end

class TestConnection
  attr_accessor :commands

  def initialize
    @commands = []
  end

  def send_command(command)
    @commands << command
  end
end

def result_iq
  "<iq type='result' id='blather0008' from='4a3fe31a-0c2a-4a9a-ae98-f5b8afb55708@127.0.0.1' to='usera@127.0.0.1/voxeo'/>"
end

def error_iq
  "<iq type='error' id='blather000c' from='4a3fe31a-0c2a-4a9a-ae98-f5b8afb55708@127.0.0.1' to='usera@127.0.0.1/voxeo'>
    <transfer xmlns='urn:xmpp:ozone:transfer:1'>
      <to>bollocks</to>
    </transfer>
    <error type='cancel'>
      <bad-request xmlns='urn:ietf:params:xml:ns:xmpp-stanzas'/>
      <text xmlns='urn:ietf:params:xml:ns:xmpp-stanzas' lang='en'>Unsupported format: bollocks</text>
    </error>
  </iq>"
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

def transfer_timeout_presence
  "<presence to='16577@app.ozone.net/1' from='9f00061@call.ozone.net/fgh4590'>
    <complete xmlns='urn:xmpp:ozone:ext:1'>
      <timeout xmlns='urn:xmpp:ozone:transfer:complete:1' />
    </complete>
  </presence>"
end

def transfer_success_presence
  "<presence to='16577@app.ozone.net/1' from='9f00061@call.ozone.net/fgh4590'>
    <complete xmlns='urn:xmpp:ozone:ext:1'>
      <success xmlns='urn:xmpp:ozone:transfer:complete:1' />
    </complete>
  </presence>"
end

def transfer_busy_presence
  %{<presence from="c82737e4-f70c-466d-b839-924f69be57bd@127.0.0.1/7d858f27-e961-4aa2-ae9f-ecaffd4c841e" to="usera@127.0.0.1/voxeo">
    <complete xmlns="urn:xmpp:ozone:ext:1">
      <busy xmlns="urn:xmpp:ozone:transfer:complete:1"/>
    </complete>
  </presence>}
end