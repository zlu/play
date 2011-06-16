require 'spec_helper'

describe Connfu::Component do
  include Connfu::Component

  describe "#say_iq" do
    before do
      Connfu.setup('host', 'password')
      Connfu.connection.stub(:write)
      Connfu::Offer.import(create_presence(offer_presence))
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
      Connfu.connection.stub(:write)
      Connfu::Offer.import(create_presence(offer_presence))
      @offer = Connfu.context.values.first
      @prompt = "Please input a four digit number"
      @ask = ask_iq(@prompt)
      @ask_node = @ask.children.first
      @prompt_node = @ask_node.children.first
      @choices_node = @prompt_node.next
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

    it 'should contain required choices node' do
      @choices_node.should be_instance_of Nokogiri::XML::Element
    end

    it 'should contain a content type attribute in choices node' do
      @choices_node.attributes['content-type'].should_not be_nil
      @choices_node.attributes['content-type'].value.should match(/application\/grammar.*/)
    end
  end

  describe '#ask' do
    it "should send ask iq to server" do
      Connfu.connection.should_receive(:write)
      ask('foo')
    end
  end

  describe '#transfer_iq' do
    before do
      Connfu.setup('host', 'password')
      Connfu.connection.stub(:write)
      Connfu::Offer.import(create_presence(offer_presence))
      @to = "sip:usera@127.0.0.1"
      @transfer = transfer_iq(@to)
    end

    it "should be an iq of type set" do
      @transfer.should be_a_kind_of Blather::Stanza::Iq
      @transfer.type.should eq :set
    end

    it "should contain a transfer node" do
      @transfer.child.name.should eq "transfer"
    end

    it "should have an ozone:transfer namespace" do
      @transfer.children.first.namespace.href.should eq "urn:xmpp:ozone:transfer:1"
    end

    it 'should contain a correct to node' do
      to_node = @transfer.children.first.children.first
      to_node.name.should eq 'to'
      to_node.text.should eq @to
    end
  end

  describe '#transfer' do
    it "should send transfer iq to server" do
      to = 'sip:usera@127.0.0.1'
      Connfu.connection.should_receive(:write)
      transfer(to)
    end
  end

  describe '#conference_iq' do
    before do
      @conf_name = 'foo_conf'
      @conference = conference_iq(@conf_name)
      @cnode = @conference.children.first
    end

    it "should be an iq of type set" do
      @conference.should be_a_kind_of Blather::Stanza::Iq
      @conference.type.should eq :set
    end

    it "should contain a name attribute" do
      name_attr = @cnode.attributes['name']
      name_attr.should_not be_nil
      name_attr.value.should eq @conf_name
    end

    it "should have an ozone:conference namespace" do
      @cnode.namespace.href.should eq 'urn:xmpp:ozone:conference:1'
    end
  end

  describe '#conference' do
    it 'should dial an outbound call first' do
      Connfu.connection.should_receive(:register_handler).with(:ready)
      conference('foo')
    end

    it 'should receive increase conference handler by 1' do
      lambda {
        conference('foo')
      }.should change{Connfu.conference_handlers.count}.by(1)
    end
  end
end