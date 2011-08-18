require 'bundler/setup'
require 'rspec'
require 'connfu'
require 'cgi'

include Connfu::Rayo::Namespacing

module ConnfuTestDsl
  def testing_dsl(&block)
    dsl_class = Class.new
    dsl_class.send(:include, Connfu::Dsl)
    dsl_class.class_eval(&block)
    before(:each) do
      @dsl_class = dsl_class
      setup_connfu(@dsl_class)
    end
    let(:dsl_instance) { dsl_class.any_instance }
  end
end

RSpec.configure do |config|
  config.include RSpec::Matchers
  config.extend ConnfuTestDsl
end

module Connfu
  class << self
    attr_writer :logger
  end
end
Connfu.logger = Logger.new(StringIO.new)
Connfu.logger.level = Logger::WARN

class MyTestClass
  include Connfu::Dsl
end

PRISM_USER = "usera"
PRISM_HOST = '127.0.0.1'
PRISM_JID = "#{PRISM_USER}@#{PRISM_HOST}"
PRISM_PASSWORD = "1"
PRISM_URI = "jid://#{PRISM_USER}:#{PRISM_PASSWORD}@#{PRISM_HOST}"

def setup_connfu(handler_class, domain='openvoice.org')
  Connfu.config.uri = PRISM_URI
  Connfu.event_processor = Connfu::EventProcessor.new(handler_class)
  Connfu.connection = TestConnection.new(domain)
end

def incoming(type, *args)
  stanza = if type.to_s =~ /_iq$/
    create_iq(send(type, *args))
  else
    create_presence(send(type, *args))
  end
  Connfu.handle_stanza(stanza)
end

def create_presence(presence_xml)
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

  def initialize(domain='openvoice.org')
    @commands = []
    @handlers = {}
    @domain = domain
  end

  def send_command(command)
    @commands << command
    command.id
  end

  def jid
    Blather::JID.new('zlu', @domain, '1')
  end

  def register_handler(type, &block)
    @handlers[type] ||= []
    @handlers[type] << block
  end

  def run
    @handlers[:ready].each { |h| h.call }
    EM.stop # break out of the loop
  end

  def wait_because_of_tropo_bug_133
    # no-op when testing
  end
end

def last_command
  Connfu.connection.commands.last
end

def result_iq(call_jid="4a3fe31a-0c2a-4a9a-ae98-f5b8afb55708@#{PRISM_HOST}", id='blather0008')
  "<iq type='result' id='#{id}' from='#{call_jid}' to='#{PRISM_JID}/voxeo'/>"
end

def error_iq(call_jid="4a3fe31a-0c2a-4a9a-ae98-f5b8afb55708@#{PRISM_HOST}", id='blather000c')
  %{<iq type='error' id='#{id}' from='#{call_jid}' to='#{PRISM_JID}/voxeo'>
    <transfer xmlns='#{tropo('transfer:1')}'>
      <to>bollocks</to>
    </transfer>
    <error type='cancel'>
      <bad-request xmlns='urn:ietf:params:xml:ns:xmpp-stanzas'/>
      <text xmlns='urn:ietf:params:xml:ns:xmpp-stanzas' lang='en'>Unsupported format: bollocks</text>
    </error>
  </iq>}
end

def offer_presence(call_jid="4a3fe31a-0c2a-4a9a-ae98-f5b8afb55708@#{PRISM_HOST}", client_jid="#{PRISM_JID}/voxeo", options={})
  offer_options = {
    :from => "<sip:16508983130@#{PRISM_HOST}>;tag=34ccaa4d",
    :to => "<sip:#{PRISM_JID}:5060>"
  }.merge(options)
  "<presence from='#{call_jid}' to='#{client_jid}'>
    <offer xmlns='#{rayo('1')}' to='sip:#{PRISM_JID}:5060' from='sip:16508983130@#{PRISM_HOST}'>
      <header name='Max-Forwards' value='70'/>
      <header name='Content-Length' value='422'/>
      <header name='Contact' value='&lt;sip:16508983130@#{PRISM_HOST}:21702&gt;'/>
      <header name='Supported' value='replaces'/>
      <header name='Allow' value='INVITE'/>
      <header name='To' value='#{CGI.escapeHTML(offer_options[:to])}'/>
      <header name='CSeq' value='1 INVITE'/>
      <header name='User-Agent' value='Bria 3 release 3.2 stamp 61503'/>
      <header name='Via' value='SIP/2.0/UDP #{PRISM_HOST}:21702;branch=z9hG4bK-d8754z-ab966854f39bb612-1---d8754z-;rport=21702'/>
      <header name='Call-ID' value='MGRkMWJiOTVmM2ViMGM4NWNiYmFhZDk5NGMwMDcwOTE.'/>
      <header name='Content-Type' value='application/sdp'/>
      <header name='From' value='#{CGI.escapeHTML(offer_options[:from])}'/>
    </offer>
  </presence>"
end

def say_success_presence(call_jid="7bc6c7d5-1428-421d-bb40-22f58cdcd2ec@#{PRISM_HOST}/a1b45d70-6df2-4460-b172-4bd077e8966d")
  "<presence from='#{call_jid}' to='#{PRISM_JID}/voxeo'>
    <complete xmlns='#{rayo('ext:1')}'>
      <success xmlns='#{tropo('say:complete:1')}'/>
    </complete>
  </presence>"
end

def ask_success_presence(call_jid="9f00061@call.ozone.net/fgh4590", catpured_input="1234")
  "<presence to='16577@app.ozone.net/1' from='#{call_jid}'>
    <complete xmlns='#{rayo('ext:1')}'>
      <success mode='speech' confidence='0.45' xmlns='#{tropo('ask:complete:1')}'>
        <interpretation>#{catpured_input}</interpretation>
        <utterance>one two three four</utterance>
      </success>
    </complete>
  </presence>"
end

def transfer_timeout_presence(call_id='9f00061')
  %{<presence to='16577@app.ozone.net/1' from='#{call_id}@call.ozone.net/fgh4590'>
    <complete xmlns='#{rayo('ext:1')}'>
      <timeout xmlns='#{tropo('transfer:complete:1')}' />
    </complete>
  </presence>}
end

def transfer_success_presence(call_id='9f00061')
  %{<presence to='16577@app.ozone.net/1' from='#{call_id}@call.ozone.net/fgh4590'>
    <complete xmlns='#{rayo('ext:1')}'>
      <success xmlns='#{tropo('transfer:complete:1')}' />
    </complete>
  </presence>}
end

def transfer_busy_presence(call_id="c82737e4-f70c-466d-b839-924f69be57bd")
  %{<presence from="#{call_id}@#{PRISM_HOST}/7d858f27-e961-4aa2-ae9f-ecaffd4c841e" to="#{PRISM_JID}/voxeo">
    <complete xmlns="#{rayo('ext:1')}">
      <busy xmlns="#{tropo('transfer:complete:1')}"/>
    </complete>
  </presence>}
end

def transfer_rejected_presence(call_id="c82737e4-f70c-466d-b839-924f69be57bd")
  %{<presence from="#{call_id}@#{PRISM_HOST}/7d858f27-e961-4aa2-ae9f-ecaffd4c841e" to="#{PRISM_JID}/voxeo">
    <complete xmlns="#{rayo('ext:1')}">
      <reject xmlns="#{tropo('transfer:complete:1')}"/>
    </complete>
  </presence>}
end

def joined_presence(call_id="9d27a2d3-9134-48ef-957e-5f5e72686d79", new_call_id="1034a58a-4ffd-479c-843e-92b84ab8826a")
  %{<presence from="#{call_id}@#{PRISM_HOST}" to="#{PRISM_JID}/voxeo">
    <joined xmlns="urn:xmpp:rayo:1" call-id="#{new_call_id}"/>
  </presence>}
end

def unjoined_presence(call_id='8c27e8c6-76c1-4cc6-a818-18075f07a511', other_call_id='56258fa4-db93-46a6-a507-0a22313e709a')
  %{<presence from="#{call_id}@#{PRISM_HOST}" to="#{PRISM_JID}/voxeo">
    <unjoined xmlns="urn:xmpp:rayo:1" call-id="#{other_call_id}"/>
  </presence>}
end

def recording_result_iq(call_id="a0565638-90f8-416e-b26f-636f1aa684d0", id="f3c1b8c4-bb4f-4f7c-a063-87ee9bac0980")
  %{<iq type="result" id="blather000a" from="#{call_id}@#{PRISM_HOST}" to="#{PRISM_JID}/voxeo">
    <ref xmlns="#{rayo('1')}" id="#{id}"/>
  </iq>}
end

def recording_stop_presence(call_id="abc123", id="def456", path="file:///tmp/recording.mp3")
  %{<presence from="#{call_id}@#{PRISM_HOST}/#{id}" to="#{PRISM_JID}/voxeo">
    <complete xmlns="#{rayo('ext:1')}">
      <stop xmlns="#{rayo('ext:complete:1')}"/>
      <recording xmlns="#{rayo('record:complete:1')}" uri="#{path}"/>
    </complete>
  </presence>}
end

def stop_presence(call_id="a27d73c5-6f5c-4a41-bfb9-6ea21b198602", id="23399310-4590-499d-8917-a0642965a096")
  %{<presence from="#{call_id}@#{PRISM_HOST}/#{id}" to="#{PRISM_JID}/voxeo">
    <complete xmlns="urn:xmpp:rayo:ext:1">
      <stop xmlns="urn:xmpp:rayo:ext:complete:1"/>
    </complete>
  </presence>}
end

def component_hangup_presence(call_id='call-id')
  %{<presence from="#{call_id}@#{PRISM_HOST}/3b1d199c-39af-4256-9a49-97293a530ac6" to="#{PRISM_JID}/voxeo">
    <complete xmlns="#{rayo('ext:1')}">
      <hangup xmlns="#{rayo('ext:complete:1')}"/>
    </complete>
  </presence>}
end

def outgoing_call_result_iq(call_id="abc123", xmpp_id="blather_001")
  %{<iq type="result" id="#{xmpp_id}" from="#{PRISM_HOST}" to="#{PRISM_JID}/voxeo">
    <ref xmlns="urn:xmpp:rayo:1" id="#{call_id}"/>
  </iq>}
end

def outgoing_call_ringing_presence(call_id="ebe45dbf-2a8b-4f1c-9aa0-1f1b39d1e821", client_jid="#{PRISM_JID}/voxeo")
  %{<presence from="#{call_id}@#{PRISM_HOST}" to="#{client_jid}">
    <ringing xmlns="#{rayo('1')}"/>
  </presence>}
end

def outgoing_call_answered_presence(call_id="ebe45dbf-2a8b-4f1c-9aa0-1f1b39d1e821")
  %{<presence from="#{call_id}@#{PRISM_HOST}" to="#{PRISM_JID}/voxeo">
    <answered xmlns="#{rayo('1')}"/>
  </presence>}
end

def hangup_presence(call_id="abc")
  %{<presence from="#{call_id}@#{PRISM_HOST}" to="#{PRISM_JID}/voxeo">
    <end xmlns="#{rayo('1')}">
      <hangup/>
    </end>
  </presence>}
end

def reject_presence(call_id="abc")
  %{<presence from="#{call_id}@#{PRISM_HOST}" to="#{PRISM_JID}/voxeo">
    <end xmlns="urn:xmpp:rayo:1">
      <reject/>
    </end>
  </presence>}
end

def timeout_presence(call_id="abc")
  %{<presence from="#{call_id}@#{PRISM_HOST}" to="#{PRISM_JID}/voxeo">
    <end xmlns="urn:xmpp:rayo:1">
      <timeout/>
    </end>
  </presence>}
end
