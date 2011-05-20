require 'spec_helper'

describe Connfu::CallCommands do
  include Connfu::CallCommands

  before do
    @client = mock('client')
    @client.stub(:write)
    Connfu.connection = @client

    @offer = create_offer
    Connfu.context = @offer
  end

  describe "#answer_iq" do
    before do
      @answer = answer_iq(@offer.from.to_s)
    end

    it "should be an iq of type set" do
      @answer.should be_a_kind_of Blather::Stanza::Iq
      @answer.type.should eq :set
    end

    it "should contain a to attribute whose value is the from attribute of offer" do
      @answer.to.should_not be_nil
      @answer.to.should eq @offer.from
    end

    it "should contain an answer node" do
      @answer.child.name.should eq "answer"
    end

    it "should have an ozone namespace" do
      @answer.children.first.namespace.href.should eq "urn:xmpp:ozone:1"
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