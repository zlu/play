require 'spec_helper'

describe Connfu::Ozone::Parser do
  describe "#parse_event_from" do
    context 'an offer iq' do
      before do
        @node = create_stanza(offer_presence)
        @event = Connfu::Ozone::Parser.parse_event_from(@node)
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

      it "should determine the call_id value of the offer" do
        @event.call_id.should eq @node.from.node
      end
    end

    context "a result iq" do
      before do
        @node = create_stanza(result_iq)
        @event = Connfu::Ozone::Parser.parse_event_from(@node)
      end

      it "should create a result event" do
        @event.should be_instance_of Connfu::Event::Result
      end
    end

    context "a say complete iq" do
      before do
        @node = create_stanza(say_complete_success)
        @event = Connfu::Ozone::Parser.parse_event_from(@node)
      end

      it "should create a SayComplete event" do
        @event.should be_instance_of Connfu::Event::SayComplete
      end

      it "should determine the call_id value of say complete" do
        @event.call_id.should eq @node.from.node
      end
    end

    context "a transfer success iq" do
      before do
        @node = create_stanza(transfer_success_iq)
        @event = Connfu::Ozone::Parser.parse_event_from(@node)
      end

      it "should create a TransferSuccess event" do
        @event.should be_instance_of Connfu::Event::TransferSuccess
      end

      it "should determine the call_id value of the transfer success iq" do
        @event.call_id.should eq @node.from.node
      end
    end

    context "a transfer timeout iq" do
      before do
        @node = create_stanza(transfer_timeout_iq)
        @event = Connfu::Ozone::Parser.parse_event_from(@node)
      end

      it "should create a TransferTimeout event" do
        @event.should be_instance_of Connfu::Event::TransferTimeout
      end

      it "should determine the call_id value of the transfer timeout iq" do
        @event.call_id.should eq @node.from.node
      end
    end
  end

end