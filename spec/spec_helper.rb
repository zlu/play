require 'rubygems'
require 'rspec'
require File.expand_path("../../lib/connfu", __FILE__)

RSpec.configure do |config|
  config.include RSpec::Matchers
  config.mock_with :rspec
end

def create_offer
  xml = "<iq type='set' id='0617104e-5574-4529-8ddd-b60e2dee4fca' from='c8a59e48-eaf6-42b4-a89b-e5c42afce2c7@10.0.2.11' to='usera@10.0.2.11/voxeo'>
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

  doc = Nokogiri::XML.parse xml
  Blather::XMPPNode.import(doc.root)
end
