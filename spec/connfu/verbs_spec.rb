require 'spec_helper'

describe Connfu::Verbs do
  include Connfu::Verbs

  before do
    Connfu.setup('host', 'password')
    EM.stub(:run)
    Connfu::start
    @offer = create_iq(offer_iq)
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
  end
end