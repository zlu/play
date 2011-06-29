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

    describe "when the handler waits and continues" do
      class HandlerWithWaits
        include Connfu::Dsl

        on :offer do
          wait
          wait
        end
      end

      before :each do
        Connfu.setup "testuser@testhost", "1"
        Connfu.handler_class = HandlerWithWaits
        Connfu.adaptor = TestConnection.new
      end

      it "ensures execution resumes after the handle_event call" do
        called_count = 0
        Connfu::EventProcessor.handle_event(Connfu::Event::Offer.new(:from => @server_address, :to => @client_address))
        called_count = called_count + 1
        Connfu::EventProcessor.handle_event(Connfu::Event::SayComplete.new)
        called_count.should eql(1)
      end
    end
  end
end
