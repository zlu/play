require 'spec_helper'

describe Connfu::OutboundCall do
  include Connfu::OutboundCall

  before do
    Connfu.setup "userb@127.0.0.1", "1"
  end

  describe 'outbound_call_iq' do
    before do
      @to_domain = '127.0.0.1'
      @from_resource = 'userb@127.0.0.1'
      @to = 'usera@127.0.0.1'
      @from= 'userb@127.0.0.1'
      @outbound_call_iq = MyTestClass.send :outbound_call_iq, @to_domain, @from_resource, @to, @from
      l.debug @outbound_call_iq.children
      @dial_node = @outbound_call_iq.children.first
    end

    it 'should be an iq' do
      @outbound_call_iq.should be_a_kind_of Blather::Stanza::Iq
    end

    it 'should be an iq of type set' do
      @outbound_call_iq.type.should eq :set
    end

    it 'should contain a to domain attribute' do
      @outbound_call_iq.to.should eq @to_domain
    end

    it 'should contain a from resource' do
      @outbound_call_iq.from.should eq @from_resource
    end

    it 'should contain a dial node' do
      @dial_node.name.should eq 'dial'
    end

    it 'should contain a correct to attribute in dial node' do
      @dial_node.attributes['to'].value.should eq @to
    end

    it 'should contain a correct from attribute in dial node' do
      @dial_node.attributes['from'].value.should eq @from
    end

    it 'should contain ozone namespace' do
      @dial_node.namespace.href.should eq "urn:xmpp:ozone:1"
    end
  end

  describe 'dial' do
    before do
      Connfu.outbound_calls = {}
    end

    let(:to) {'foo_number'}
    let(:call) {dial(to)}

    it 'should register a ready handler with a block' do
      Connfu.connection.should_receive(:register_handler).with(:ready, &lambda{})
      MyTestClass.send :dial, ''
    end

    it 'dial the after connection is ready' do
      MyTestClass.send :dial, 'sip_number'
      Connfu.connection.should_receive(:write)
      Connfu.connection.send :call_handler_for, :ready, ''
    end

    it 'should return a call object' do
      call.should be_instance_of Connfu::Call
      call.to.should eq to
    end

    it 'should increase the count of outbound calls by 1' do
      lambda {
        dial(to)
      }.should change{Connfu.outbound_calls.count}.by(1)
    end
  end
end