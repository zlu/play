require 'spec_helper'

describe Connfu::Verbs do
  include Connfu::Verbs

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

  describe "#say_iq" do
    before do
      @text_to_say = "Oh yeah, connfu is awesome"
      @say = say_iq(@offer.from.to_s, @text_to_say)
    end

    it "should be an iq of type set" do
      @say.should be_a_kind_of Blather::Stanza::Iq
      @say.type.should eq :set
    end

    it "should contain a say node" do
      @say.child.name.should eq "say"
    end

    it "should have an ozone:say namespace" do
      @say.children.first.namespace.href.should eq "urn:xmpp:ozone:say:1"
    end
  end

  describe "#say" do
    before do
      @text_to_say = "Oh yeah, connfu is awesome"
    end

    it "should send say iq to server" do
      @client.should_receive(:write)
      say(@text_to_say)
    end

    it "should ont respond to ringing event" do
      pending
    end

    it "should respond to answered event" do
      pending
    end
  end
end