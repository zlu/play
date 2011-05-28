require 'spec_helper'

include Connfu::IqParser

class TestClass
  include Connfu
end

describe Connfu::IqParser do
  before do
    Connfu.setup('host', 'password')
    @dp = Connfu.dsl_processor
    @dp.handlers = ["answer", {"say" => 'foo bar'}, "hangup"]
  end

  describe "#parse" do
    it "should create an offer for offer iq" do
      offer = Connfu::IqParser.parse(create_iq(offer_iq))
      offer.should be_instance_of Connfu::Offer
      offer.id.should eq offer_iq.match(/.*id='(.*)'\sfrom=.*/)[1]
    end

    it "should create a result for result iq" do
      result = Connfu::IqParser.parse(create_iq(result_iq))
      result.should be_instance_of Connfu::Result
      result.id.should eq result_iq.match(/.*id='(.*)'\sfrom=.*/)[1]
    end

    it "should create an error for error iq" do
      error = Connfu::IqParser.parse(create_iq(error_iq))
      error.should be_instance_of Connfu::Error
      error.id.should eq error_iq.match(/.*id='(.*)'\sfrom=.*/)[1]
    end

    it "should create a complete event for say" do
      say_complete = Connfu::IqParser.parse(create_iq(say_complete_iq))
      say_complete.should be_instance_of Connfu::Event::SayComplete
      say_complete.get_attribute(:from).should eq say_complete_iq.match(/.*from='(.*)'>\s.*/)[1]
    end

    it "should handle unknown type of incoming iq" do
      pending 'need to find out what unknown iq or string can come from prism'
    end
  end

  describe "#fire_event" do
    it "should reduce command handlers by 1" do
      TestClass.stub(:answer)
      lambda {
        Connfu::IqParser.fire_event(TestClass)
      }.should change { @dp.handlers.size }.by(-1)
    end

    context "when one event is fired" do
      it "should cause the answer command to execute" do
        TestClass.should_receive(:answer)
        Connfu::IqParser.fire_event(TestClass)
      end
    end

    context "when two events are fired" do
      before do
        TestClass.stub(:answer)
        Connfu::IqParser.fire_event(TestClass)
      end

      it "should cause the say, the 2nd command in handlers, to execute" do
        TestClass.should_receive(:say)
        Connfu::IqParser.fire_event(TestClass)
      end
    end
  end
end