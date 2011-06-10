require 'spec_helper'

describe Connfu::IqParser do
  before do
    Connfu.setup('host', 'password')
    @dp = Connfu.dsl_processor
    @dp.handlers = ["answer", {"say" => 'foo bar'}, "hangup"]
  end

  describe "#parse" do
    context 'an offer iq' do
      before do
        Connfu.connection.stub(:write)
        @offer = Connfu::Offer.import(create_iq(offer_iq))
      end

      it "should create an offer" do
        @offer.should be_instance_of Connfu::Offer
        @offer.id.should eq offer_iq.match(/.*id='(.*)'\sfrom=.*/)[1]
      end
    end

    it "should create a result for result iq" do
      result = Connfu::IqParser.parse(create_iq(result_iq))
      result.should be_instance_of Connfu::Event::Result
      result.id.should eq result_iq.match(/.*id='(.*)'\sfrom=.*/)[1]
    end

    it "should create an error for error iq" do
      error = Connfu::IqParser.parse(create_iq(error_iq))
      error.should be_instance_of Connfu::Error
      error.id.should eq error_iq.match(/.*id='(.*)'\sfrom=.*/)[1]
    end

    it "should create a complete event for say" do
      Connfu::IqParser.stub(:fire_event)
      say_complete = Connfu::IqParser.parse(create_iq(say_complete_iq))
      say_complete.should be_instance_of Connfu::Event::SayComplete
      say_complete.get_attribute(:from).should eq say_complete_iq.match(/.*from='(.*)'>\s.*/)[1]
    end

    it "should handle unknown type of incoming iq" do
      pending 'need to find out what unknown iq or string can come from prism'
    end

    it "should set the connfu context after parsing" do
      pending 'maybe removed if to and from can be obtain in other fashion'
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

    context "firing two events" do
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
        pending
      end
    end
  end
end