require 'spec_helper'

describe Connfu::CallCommands do
  include Connfu::CallCommands

  before do
    Connfu.connection = mock('connection')
    Connfu.setup('host', 'password')
    Connfu.connection.stub(:write)
    @offer = create_presence(offer_presence)
    Connfu::Offer.import(@offer)
    @call_commands = ['accept', 'answer', 'hangup', 'reject']
  end

  describe "call_commands_iq" do
    it "should create an iq method for each call command" do
      @call_commands.each do |call_command|
        MyTestClass.should respond_to :"#{call_command}_iq"
      end
    end

    it "should be an iq of type set" do
      @call_commands.each do |call_command|
        cc_iq = MyTestClass.send :"#{call_command}_iq"
        cc_iq.should be_a_kind_of Blather::Stanza::Iq
        cc_iq.type.should eq :set
      end
    end

    it "should contain a to attribute whose value is the from attribute of offer" do
      @call_commands.each do |call_command|
        cc_iq = MyTestClass.send :"#{call_command}_iq"
        cc_iq.to.should_not be_nil
        cc_iq.to.should eq @offer.from
      end
    end

    it "should contain a from attribute whose value is the to attribute of offer" do
      @call_commands.each do |call_command|
        cc_iq = MyTestClass.send :"#{call_command}_iq"
        cc_iq.from.should_not be_nil
        cc_iq.from.should eq @offer.to
      end
    end

    it "should contain an call_command node" do
      @call_commands.each do |call_command|
        cc_iq = MyTestClass.send :"#{call_command}_iq"
        cc_iq.child.name.should eq call_command
      end
    end

    it "should have an ozone namespace" do
      @call_commands.each do |call_command|
        cc_iq = MyTestClass.send :"#{call_command}_iq"
        cc_iq.children.first.namespace.href.should eq "urn:xmpp:ozone:1"
      end
    end
  end

  describe "call_command" do
    before do
      @call_commands.delete_if { |item| item == 'redirect' }
    end

    it "should create a method for each call_command" do
      @call_commands.each do |call_command|
        MyTestClass.should respond_to :"#{call_command}"
      end
    end

    it "should send call command iq to server" do
      #TODO enable with regex
      @call_commands.each do |call_command|
        Connfu.connection.should_receive(:write) #.with(/#{call_command}/)
        eval "#{call_command}"
      end
    end
  end

  describe "redirect" do
    it "should respond to redirect" do
      MyTestClass.should respond_to :redirect
    end

    it "should include to attribute in the redirect command iq" do
      #TODO enable with regex
      to = "14151112222"
      Connfu.connection.should_receive(:write) #.with(/#{to}/)
      eval "redirect(#{to})"
    end
  end
end