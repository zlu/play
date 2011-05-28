require 'spec_helper'

include Connfu::IqParser

class TestClass
  include Connfu
end

describe Connfu::IqParser do
  describe "#parse" do
    it "should create an offer for offer iq" do
      offer = Connfu::IqParser.parse(create_iq(offer_iq))
      offer.should be_instance_of Connfu::Offer
      offer.id.should eq offer_iq.match(/.*id='(.*)'\sfrom=.*/)[1]
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
  end

  describe "#fire_event" do
    before do
      @dp = Connfu::DslProcessor.new
      Connfu::DslProcessor.handlers = ["answer", "say", "hangup"]
    end

    it "should reduce command handlers by 1" do
      TestClass.stub(:answer)
      lambda { Connfu::IqParser.fire_event(TestClass) }.should change { Connfu::DslProcessor.handlers.size }.by(-1)
    end

    context "for the first time" do
      it "should cause the answer command to execute" do
        TestClass.should_receive(:answer)
        Connfu::IqParser.fire_event(TestClass)
      end
    end

    context "for the second time" do
      it "should cause the say command to execute" do

        pending

        TestClass.should_receive(:say)
        Connfu::IqParser.fire_event(TestClass)
        Connfu::IqParser.fire_event(TestClass)
      end
    end
  end
end