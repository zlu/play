require 'spec_helper'

describe Connfu::IqParser do
  describe "#parse_event_from" do
    context 'an offer iq' do
      before do
        @node = create_stanza(offer_presence)
        @event = Connfu::IqParser.parse_event_from(@node)
      end

      it "should create an offer event" do
        @event.should be_instance_of Connfu::Event::Offer
      end

      it "should determine the from value of the offer" do
        @event.presence_from.should eq @node.attributes['from'].value
      end

      it "should determine the to value of the offer" do
        @event.presence_to.should eq @node.attributes['to'].value
      end
    end

    context "a result iq" do
      before do
        @node = create_stanza(result_iq)
        @event = Connfu::IqParser.parse_event_from(@node)
      end

      it "should create a result event" do
        @event.should be_instance_of Connfu::Event::Result
      end
    end

    context "a say complete iq" do
      before do
        @node = create_stanza(say_complete_success)
        @event = Connfu::IqParser.parse_event_from(@node)
      end

      it "should create a SayComplete event" do
        @event.should be_instance_of Connfu::Event::SayComplete
      end
    end
  end

  describe "#handle_event" do
    before do
      Connfu.handler = mock("call_handler")
    end

    it "a result event" do
      Connfu.handler.should_not_receive(:continue)
      Connfu::IqParser.handle_event(Connfu::Event::Result.new)
    end

    it "a say complete" do
      Connfu.handler.should_receive(:continue)
      Connfu::IqParser.handle_event(Connfu::Event::SayComplete.new)
    end
  end


end