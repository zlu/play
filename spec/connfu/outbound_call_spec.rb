require 'spec_helper'

describe Connfu::OutboundCall do
  include Connfu::OutboundCall

  class MyClass
    include Connfu
  end

  before do
    Connfu.setup "userb@127.0.0.1", "1"
  end

  describe 'outbound_call_iq' do
    before do
      @to_domain = '127.0.0.1'
      @from_resource = 'userb@127.0.0.1'
      @to = 'usera@127.0.0.1'
      @from= 'userb@127.0.0.1'
      @outbound_call_iq = MyClass.send :outbound_call_iq, @to_domain, @from_resource, @to, @from
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
    it 'should write to connfu::connection' do
      #TODO should test parameters to write
      Connfu.connection.should_receive(:write)
      MyClass.send :dial, 'foo'
    end
  end
end