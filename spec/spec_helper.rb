require 'rubygems'
require 'rspec'
require File.expand_path("../../lib/connfu", __FILE__)

RSpec.configure do |config|
  config.include RSpec::Matchers
  config.mock_with :mocha
end

class MyTestClass
  include Connfu
end

def create_iq(iq_xml)
  doc = Nokogiri::XML.parse iq_xml
  Blather::Stanza::Iq.import(doc.root)
end

def create_stanza(presence_xml)
  doc = Nokogiri::XML.parse presence_xml
  Blather::Stanza::Presence.import(doc.root)
end

RSpec::Matchers.define :be_stanzas do |expected_stanzas|
  match do |actual|
    actual.map { |x| x.to_s.gsub(/\n\s*/, "\n") } == expected_stanzas.map { |x| x.to_s.gsub(/\n\s*/, "\n") }
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

def error_iq_for_answer
  "<iq type='error' id='blather0009' from='1942e51e-61f2-47b1-97bf-8cccbc6d4683@localhost' to='usera@localhost/voxeo'>
    <answer xmlns='urn:xmpp:ozone:1'/>
    <error type='cancel'>
      <internal-server-error xmlns='urn:ietf:params:xml:ns:xmpp-stanzas'/>
    </error>
    <detail>Failed to join to media server [call=com.tropo.server.CallActor@89183d]</detail>
  </iq>"
end

def error_iq_for_answer_with_text
  "<iq type='error' id='blather000c' from='usera@localhost/voxeo' to='usera@localhost/voxeo'>
    <answer xmlns='urn:xmpp:ozone:1'/>
    <error type='cancel'>
      <item-not-found xmlns='urn:ietf:params:xml:ns:xmpp-stanzas'/>
      <text xmlns='urn:ietf:params:xml:ns:xmpp-stanzas' lang='en'>Could not find call [id=usera]</text>
    </error>
  </iq>"
end

def say_complete_success
  "<presence from='7bc6c7d5-1428-421d-bb40-22f58cdcd2ec@127.0.0.1/a1b45d70-6df2-4460-b172-4bd077e8966d' to='usera@127.0.0.1/voxeo'>
    <complete xmlns='urn:xmpp:ozone:ext:1'>
      <success xmlns='urn:xmpp:ozone:say:complete:1'/>
    </complete>
  </presence>"
end

def outbound_call_iq
  "<iq type='set' to='call.ozone.net' from='16577@app.ozone.net/1'>
     <dial to='tel:+13055195825' from='tel:+14152226789' xmlns='urn:xmpp:ozone:1'>
        <header name='x-skill' value='agent' />
        <header name='x-customer-id' value='8877' />
     </dial>
  </iq>"
end

def ask_iq
  "<iq type='set' to='9f00061@call.ozone.net/1' from='16577@app.ozone.net/1'>
    <ask xmlns='urn:xmpp:ozone:ask:1'
        bargein='true'
        min-confidence='0.3'
        mode='speech|dtmf|any'
        recognizer='en-US'
        terminator='#'
        timeout='12000'>
      <prompt voice='allison'>
        Please enter your four digit pin
      </prompt>
      <choices content-type='application/grammar+voxeo'>
        [4 DIGITS]
      </choices>
    </ask>
  </iq>"
end

def ask_complete_success
  "<presence to='16577@app.ozone.net/1' from='9f00061@call.ozone.net/fgh4590'>
    <complete xmlns='urn:xmpp:ozone:ext:1'>
      <success mode='speech' confidence='0.45' xmlns='urn:xmpp:ozone:ask:complete:1'>
        <interpretation>1234</interpretation>
        <utterance>one two three four</utterance>
      </success>
    </complete>
  </presence>"
end

def transfer_iq
  "<iq type='set' to='9f00061@call.ozone.net/1' from='16577@app.ozone.net/1'>
    <transfer xmlns='urn:xmpp:ozone:transfer:1'
        from='tel:+14152226789'
        terminator='*'
        timeout='120000'
        answer-on-media='true'>
      <to>tel:+4159996565</to>
      <to>tel:+3059871234</to>
      <ring voice='allison'>
        <audio url='http://acme.com/transfering.mp3'>
            Please wait while your call is being transfered.
        </audio>
      </ring>
      <header name='x-skill' value='agent' />
      <header name='x-customer-id' value='8877' />
    </transfer>
  </iq>"
end

def spec_conference_iq
  "<iq type='set' to='9f00061@call.ozone.net/1' from='16577@app.ozone.net/1'>
     <conference xmlns='urn:xmpp:ozone:conference:1'
      name='1234'
      mute='false'
      terminator='*'
      tone-passthrough='true'
      moderator='true'>
      <announcement voice='allison'>
        Jose de Castro has entered the conference
      </announcement>
      <music voice='herbert'>
        The moderator how not yet joined.. Listen to this awesome music while you wait.
        <audio url='http://www.yanni.com/music/awesome.mp3' />
      </music>
    </conference>
  </iq>"
end

def outbound_result_iq
  "<iq type='result' to='16577@app.ozone.net/1' from='call.ozone.net'>
     <ref id='9f00061' xmlns='urn:xmpp:ozone:1'/>
  </iq>"
end

def answered_event
  "<presence to='16577@app.ozone.net/1' from='9f00061@call.ozone.net/1'>
    <answered xmlns='urn:xmpp:ozone:1' />
  </presence>"
end

def ringing_event
  "<presence to='16577@app.ozone.net/1' from='9f00061@call.ozone.net/1'>
    <ringing xmlns='urn:xmpp:ozone:1' />
  </presence>"
end

#%w[timeout, busy, reject].each do |reason|
#  define_method :"end_with_#{reason}_event" do
#    "<presence to='16577@app.ozone.net/1' from='9f00061@call.ozone.net/1'>
#    <end xmlns='urn:xmpp:ozone:1'>
#      <\"#{timeout}\" />
#    </end>
#  </presence>"
#  end
#end

def end_event
  "<presence to='16577@app.ozone.net/1' from='9f00061@call.ozone.net/1'>
    <end xmlns='urn:xmpp:ozone:1'>
    </end>
  </presence>"
end

def end_with_timeout_event
  "<presence to='16577@app.ozone.net/1' from='9f00061@call.ozone.net/1'>
    <end xmlns='urn:xmpp:ozone:1'>
      <timeout />
    </end>
  </presence>"
end

def end_with_busy_event
  "<presence to='16577@app.ozone.net/1' from='9f00061@call.ozone.net/1'>
    <end xmlns='urn:xmpp:ozone:1'>
      <busy />
    </end>
  </presence>"
end

def end_with_reject_event
  "<presence to='16577@app.ozone.net/1' from='9f00061@call.ozone.net/1'>
    <end xmlns='urn:xmpp:ozone:1'>
      <reject />
    </end>
  </presence>"
end

def end_with_error_event
  "<presence to='16577@app.ozone.net/1' from='9f00061@call.ozone.net/1'>
    <end xmlns='urn:xmpp:ozone:1'>
      <error>Error answering the call</error>
    </end>
  </presence>"
end
