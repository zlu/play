require 'spec_helper'

describe Connfu do
  before do
    @uri = 'jid://foo:password@bar.com'
    Connfu.config.uri = @uri
    Connfu.connection = TestConnection.new
  end

  describe "#start" do
    it "should start the EventMachine" do
      EM.should_receive(:run)
      Connfu.start(MyTestClass)
    end

    it "should process the dial queue every second" do
      EM.should_receive(:add_periodic_timer).with(1, an_instance_of(Connfu::Queue::Worker))
      Connfu.start(MyTestClass)
    end

    it "should call the on_ready method of the handler class" do
      MyTestClass.should_receive(:on_ready)
      Connfu.start(MyTestClass)
    end

    describe "called with a class" do
      it "sets the event processor to one based on the handler class" do
        Connfu.start(MyTestClass)
        Connfu.event_processor.should_not be_nil
        Connfu.event_processor.handler_class.should eql(MyTestClass)
      end
    end

    describe "called with a block" do
      it "sets the event processor to one based on a class built with the block" do
        Connfu.start do
          attr_reader :smoke_signal
        end
        Connfu.event_processor.should_not be_nil
        handler_class = Connfu.event_processor.handler_class
        handler_class.included_modules.include?(Connfu::Dsl).should be_true
        handler = handler_class.new({})
        handler.respond_to?(:smoke_signal).should be_true
      end
    end
  end
end