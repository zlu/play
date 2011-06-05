require 'spec_helper'

describe Connfu::Component do
  include Connfu::Component

  describe "#say_iq" do
    before do
      Connfu.setup('host', 'password')
      EM.stub(:run)
      Connfu::start
      Connfu.connection.stub(:write)
      Connfu::Offer.import(create_iq(offer_iq))
      @text_to_say = "Oh yeah, connfu is awesome"
      @say = say_iq(@text_to_say)
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
      Connfu.connection.should_receive(:write)
      say(@text_to_say)
    end
  end

  describe '#ask_iq' do
    before do
      Connfu.setup('host', 'password')
      EM.stub(:run)
      Connfu::start
      Connfu.connection.stub(:write)
      Connfu::Offer.import(create_iq(offer_iq))
      @offer = Connfu.context.values.first
      @prompt = "Please input a four digit number"
      @ask = ask_iq(@prompt)
      @ask_node = @ask.children.first
      @prompt_node = @ask_node.children.first
    end

    it 'should by an iq of type set' do
      @ask.should be_instance_of Blather::Stanza::Iq
    end

    it 'should contain a to resource' do
      @ask.to.should eq @offer.from
    end

    it 'should contain a from resource' do
      @ask.from.should eq @offer.to
    end

    it 'should contain an ask node' do
      @ask_node.name.should eq 'ask'
    end

    it 'should contain a prompt node' do
      @prompt_node.name.should eq 'prompt'
    end

    it 'should contain correct text in the prompt node' do
      @prompt_node.text.should eq @prompt
    end

    it 'should contain ozone namespace' do
      @ask_node.namespace.href.should eq "urn:xmpp:ozone:ask:1"
    end
  end

  describe '#ask' do
    it "should send ask iq to server" do
      Connfu.connection.should_receive(:write)
      ask('foo')
    end
  end
end