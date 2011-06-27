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

      # it "should determine the id" do
      #   @event.id.should eq @node.attributes['id'].value
      # end
    end

    context "a say complete iq" do
      before do
        @node = create_stanza(say_complete_success)
        @event = Connfu::IqParser.parse_event_from(@node)
      end

      it "should create a SayComplete event" do
        @event.should be_instance_of Connfu::Event::SayComplete
      end

      # it "should expose the from value of the say complete event" do
      #   @event.from.should eq @node.attributes['from'].value
      # end
    end

    # context 'for ask complete' do
    #   before do
    #     @ask_complete_stanza = create_stanza(ask_complete_success)
    #   end
    #
    #   it 'should create a complete event for ask' do
    #     @ask_complete = Connfu::IqParser.parse(@ask_complete_stanza)
    #     @ask_complete.should be_instance_of Connfu::Event::AskComplete
    #   end
    # end
    #
    # context 'for outbound call' do
    #   before do
    #     @oc_iq = create_iq(outbound_result_iq)
    #   end
    #
    #   it 'should create a result iq for outbound call' do
    #     @oc_result = Connfu::IqParser.parse(@oc_iq)
    #     @oc_result.should be_instance_of Connfu::Event::OutboundResult
    #   end
    # end
    #
    # it 'should be able to parse answered event' do
    #   Connfu::Call.stub(:update_state)
    #   answered = Connfu::IqParser.parse(create_stanza(answered_event))
    #   answered.should be_instance_of Connfu::Event::Answered
    # end
    #
    # context 'for end event' do
    #   before do
    #     l.debug end_stanza = create_stanza(end_event)
    #     @end = Connfu::IqParser.parse(end_stanza)
    #   end
    #
    #   it 'should create an end event' do
    #     @end.should be_instance_of Connfu::Event::End
    #   end
    # end
  end

  describe "#handle_event" do
    before do
      Connfu.handler = mock("connection_handler")
    end

    it "a result event" do
      Connfu.handler.should_not_receive(:handle)
      Connfu::IqParser.handle_event(Connfu::Event::Result.new)
    end

    it "a say complete" do
      Connfu.handler.should_receive(:handle)
      Connfu::IqParser.handle_event(Connfu::Event::SayComplete.new)
    end
  end


end