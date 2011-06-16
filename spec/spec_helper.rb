require 'rubygems'
require 'rspec'
require File.expand_path("../../lib/connfu", __FILE__)

RSpec.configure do |config|
  config.include RSpec::Matchers
  config.mock_with :rspec
end

class MyTestClass;
  include Connfu;
end

def create_iq(iq_xml)
  doc = Nokogiri::XML.parse iq_xml
  Blather::Stanza::Iq.import(doc.root)
end

def create_presence(presence_xml)
  doc = Nokogiri::XML.parse presence_xml
  Blather::Stanza::Presence.import(doc.root)
end

def result_iq
  "<iq type='result' id='blather000b' from='localhost' to='usera@localhost/voxeo'/>"
end

def offer_iq
  "<iq type='set' id='0617104e-5574-4529-8ddd-b60e2dee4fca' from='c8a59e48-eaf6-42b4-a89b-e5c42afce2c7@10.0.2.11' to='usera@10.0.2.11/voxeo'>
      <offer xmlns='urn:xmpp:ozone:1' to='sip:usera@10.0.2.11' from='sip:foobar@localhost'>
        <header name='Max-Forwards' value='70'/>
        <header name='Content-Length' value='365'/>
        <header name='Contact' value='&lt;sip:hbylmfud@10.0.2.1:6065&gt;'/>
        <header name='Supported' value='100rel'/>
        <header name='Allow' value='SUBSCRIBE'/>
        <header name='To' value='&lt;sip:usera@10.0.2.11&gt;'/>
        <header name='CSeq' value='4810 INVITE'/>
        <header name='User-Agent' value='Blink 0.24.0 (MacOSX)'/>
        <header name='Via' value='SIP/2.0/UDP 192.168.10.131:6065;rport=6065;branch=z9hG4bKPjTP0V8grdf5mRJI8CtCnEA1fy7h1CMqLD;received=10.0.2.1'/>
        <header name='Call-ID' value='IS08DO5F62Th5ekZU18v56xkEOeWoFiQ'/>
        <header name='Content-Type' value='application/sdp'/>
        <header name='From' value='LocalTesting &lt;sip:foobar@localhost&gt;;tag=3kJ52w8ZiE7tdUTxtnoWM8MXcOb-deNj'/>
      </offer>
    </iq>"
end

def offer_presence
  "<presence from='4a3fe31a-0c2a-4a9a-ae98-f5b8afb55708@127.0.0.1' to='usera@127.0.0.1/voxeo'>
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

def error_iq
  "<iq type='set' id='1c291bf2-db31-4b0f-bd95-dea4b58c3496' from='1942e51e-61f2-47b1-97bf-8cccbc6d4683@localhost' to='usera@localhost/voxeo'>
    <end xmlns='urn:xmpp:ozone:1'>
      <error/>
    </end>
  </iq>"
end

def say_complete_iq
  "<iq type='set' to='16577@app.ozone.net/1' from='9f00061@call.ozone.net/fgh4590'>
     <complete reason='success' xmlns='urn:xmpp:ozone:say:1'>
   </iq>"
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

def complete_for_ask_iq
  "<iq type='set' id='47b63bdd-4b60-45b9-974f-1217068f09f8'
       from='b30bedad-a48e-4dea-b8ef-9d05f40759c7@127.0.0.1/c41520e1-9789-4439-b388-9ce1f3b97e86'
       to='usera@127.0.0.1/voxeo'>
     <complete xmlns='urn:xmpp:ozone:ask:1'
               reason='SUCCESS'
               concept='1111' interpretation='1111' confidence='1.0' utterance='1111'/>
  </iq>"
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
  "<iq type='result' id='blather0008' from='127.0.0.1' to='usera@127.0.0.1/voxeo'>
    <ref jid='bdd11c28-c2b0-4e05-a406-021c3a47fc1f@127.0.0.1' xmlns='urn:xmpp:ozone:1'>
      <title />
    </ref>
  </iq>"
#  "<iq type='result' to='16577@app.ozone.net/1' from='call.ozone.net'>
#     <ref id='9f00061' />
#  </iq>"
end

def answered_event_iq
  "<iq to='16577@app.ozone.net/1' from='9f00061@call.ozone.net/1'>
    <answered xmlns='urn:xmpp:ozone:1' />
  </iq>"
end

def temp_answered_event_iq
  "<iq type='set' id='ab7dba28-3f26-4edc-af4e-19b63a3f254f' from='2e3cbaa6-4de3-426a-ac0a-249287a38ba6@127.0.0.1' to='usera@127.0.0.1/voxeo'>
    <info xmlns='urn:xmpp:ozone:1'>
      <answer/>
    </info>
  </iq>"
end