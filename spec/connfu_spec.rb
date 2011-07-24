require 'spec_helper'

describe Connfu do
  before do
    @uri = 'jid://foo:password@bar.com'
    Connfu.config.uri = @uri
  end

  describe "#start" do
    it "should start the EventMachine" do
      EM.should_receive(:run)
      Connfu.start(MyTestClass)
    end

    it "should process the dial queue every second" do
      EM.should_receive(:add_periodic_timer).with(1, an_instance_of(Connfu::Queue::Worker)).and_raise(StandardError)
      lambda { Connfu.start(MyTestClass) }.should raise_error(StandardError)
    end
  end
end