require 'rubygems'
require 'rspec'
require File.expand_path("../../lib/connfu", __FILE__)

RSpec.configure do |config|
  config.include RSpec::Matchers
  config.mock_with :rspec
end

def create_iq(iq_xml)
  doc = Nokogiri::XML.parse iq_xml
  Blather::Stanza::Iq.import(doc.root)
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