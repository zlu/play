require 'spec_helper'

describe Connfu::Verbs do
  include Connfu::Verbs
  
  before do
    @offer = create_offer
    Connfu.context = @offer
    @answer = answer_iq(@offer.from.to_s)
  end

  describe "#answer_iq" do
    it "should be an iq of type set" do
      @answer.should be_a_kind_of Blather::Stanza::Iq
      @answer.type.should eq :set
    end

    it "should contain a to attribute whose value is the from attribute of offer" do
      @answer.to.should_not be_nil
      @answer.to.should eq @offer.from
    end

    it "should contain an namespaced answer node" do
      @answer.child.name.should eq "answer"
      @answer.children.first.namespace.href.should eq "urn:xmpp:ozone:1"
    end
  end

  describe "#answer" do
    before do
      @client = mock('client')
      @client.stub(:write)
      Connfu.connection = @client
    end

    it "should send answer iq to server" do
      @client.should_receive(:write)
      answer
    end

    it "should only respond to ringing event" do
      pending
    end
  end
end