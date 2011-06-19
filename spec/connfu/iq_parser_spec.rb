require 'spec_helper'

describe Connfu::IqParser do
  before do
    Connfu.setup('host', 'password')
    @dp = Connfu.dsl_processor
    @dp.handlers = ["answer", {"say" => 'foo bar'}, "hangup"]
  end

  describe "#parse" do
    before do
      Connfu.connection.stub(:write)
      Connfu::IqParser.stub(:fire_event)
    end

    context 'an offer iq' do
      before do
        @offer_node = create_stanza(offer_presence)
        @offer = Connfu::Offer.import(@offer_node)
      end

      it "should create an offer" do
        @offer.should be_instance_of Connfu::Offer
        @offer.to.should eq @offer_node.attributes['to'].value
        @offer.from.should eq @offer_node.attributes['from'].value
      end
    end

    it "should create a result for result iq" do
      result = Connfu::IqParser.parse(create_iq(result_iq))
      result.should be_instance_of Connfu::Event::Result
      result.id.should eq result_iq.match(/.*id='(.*)'\sfrom=.*/)[1]
    end

    it "should create a complete event for say" do
      Connfu::IqParser.stub(:fire_event)
      say_complete = Connfu::IqParser.parse(create_iq(say_complete_success))
      say_complete.should be_instance_of Connfu::Event::SayComplete
      say_complete.get_attribute(:from).should eq create_stanza(say_complete_success).attributes['from'].value
    end

    context 'for ask complete' do
      before do
        @ask_complete_stanza = create_stanza(ask_complete_success)
      end

      it 'should create a complete event for ask' do
        @dp.handlers = [{:ask=>"please enter a four digit pin"}]
        @dp.ask_handler = {'result'=>"say((\"your input is \" + result))"}
        @ask_complete = Connfu::IqParser.parse(@ask_complete_stanza)
        Connfu::IqParser.stub(:fire_event)
        @ask_complete.should be_instance_of Connfu::Event::AskComplete
      end
    end

    context 'for outbound call' do
      before do
        @oc_iq = create_iq(outbound_result_iq)
      end

      it 'should create a result iq for outbound call' do
        @oc_result = Connfu::IqParser.parse(@oc_iq)
        @oc_result.should be_instance_of Connfu::Event::OutboundResult
      end
    end

    it 'should be able to parse answered event' do
      answered = Connfu::IqParser.parse(create_stanza(answered_event))
      answered.should be_instance_of Connfu::Event::Answered
    end

    context 'for end event' do
      before do
        l.debug end_stanza = create_stanza(end_event)
        @end = Connfu::IqParser.parse(end_stanza)
      end

      it 'should create an end event' do
        @end.should be_instance_of Connfu::Event::End
      end
    end
  end

  describe "#fire_event" do
    it "should reduce command handlers by 1" do
      Connfu.connection.stub(:write)
      lambda {
        Connfu::IqParser.fire_event
      }.should change { @dp.handlers.size }.by(-1)
    end

    context "firing one event" do
      it "should cause the answer command to execute" do
        MyTestClass.should_receive(:answer)
        Connfu::IqParser.fire_event
      end
    end

    context 'firing two events' do
      before do
        MyTestClass.stub(:answer)
        Connfu::IqParser.fire_event
      end

      it "should cause the say to execute" do
        MyTestClass.should_receive(:say)
        Connfu::IqParser.fire_event
      end
    end

    context 'when hangup is going to be called' do
      before do
        @dp.handlers = ['hangup']
      end

      it "should not call hangup for result iq" do
        pending 'how to handle hangup correctly - maybe add boolean param for synchronisation'
        incoming_iq = create_iq(result_iq)
        MyTestClass.should_not_receive(:hangup)
        Connfu.connection.send :call_handler_for, :iq, incoming_iq
      end
    end
  end
end