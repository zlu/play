require 'spec_helper'

describe Connfu::EventProcessor do
  describe "#handle_event" do
    before do
      Connfu.handler = mock("call_handler")
    end

    it "a result event" do
      Connfu.handler.should_not_receive(:continue)
      Connfu::EventProcessor.handle_event(Connfu::Event::Result.new)
    end

    it "a say complete" do
      Connfu.handler.should_receive(:continue)
      Connfu::EventProcessor.handle_event(Connfu::Event::SayComplete.new)
    end
  end
end