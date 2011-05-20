require 'spec_helper'

describe Connfu::CallCommands do
  include Connfu::CallCommands

  class MyClass; include Connfu; end

  before do
    @client = mock('client')
    @client.stub(:write)
    Connfu.connection = @client

    @offer = create_offer
    Connfu.context = @offer

    @call_commands = ['accept', 'answer', 'hangup', 'reject']
  end

  describe "call_commands" do
    it "should create a iq method for each call command" do
      @call_commands.each do |call_command|
        MyClass.should respond_to :"#{call_command}_iq"
      end
    end

    it "should be an iq of type set" do
      @call_commands.each do |call_command|
        cc_iq = MyClass.send :"#{call_command}_iq", @offer.from.to_s
        cc_iq.should be_a_kind_of Blather::Stanza::Iq
        cc_iq.type.should eq :set
      end
    end

    it "should contain a to attribute whose value is the from attribute of offer" do
      @call_commands.each do |call_command|
        cc_iq = MyClass.send :"#{call_command}_iq", @offer.from.to_s
        cc_iq.to.should_not be_nil
        cc_iq.to.should eq @offer.from
      end
    end

    it "should contain an call_command node" do
      @call_commands.each do |call_command|
        cc_iq = MyClass.send :"#{call_command}_iq", @offer.from.to_s
        cc_iq.child.name.should eq call_command
      end
    end

    it "should have an ozone namespace" do
      @call_commands.each do |call_command|
        cc_iq = MyClass.send :"#{call_command}_iq", @offer.from.to_s
        cc_iq.children.first.namespace.href.should eq "urn:xmpp:ozone:1"
      end
    end
  end

  describe "#answer" do
    it "should send answer iq to server" do
      @client.should_receive(:write)
      answer
    end

    it "should only respond to ringing event" do
      pending
    end

    it "should change state from ringing to answered" do
      pending
    end
  end

end