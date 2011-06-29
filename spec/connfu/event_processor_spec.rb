require 'spec_helper'

describe Connfu::EventProcessor do
  describe "#handle_event" do
    describe "when the handler waits and continues" do
      class HandlerWithWaits
        include Connfu::Dsl

        on :offer do
          wait
          wait
        end
      end

      before :each do
        @event_processor = Connfu::EventProcessor.new(HandlerWithWaits)
        Connfu.adaptor = TestConnection.new
      end

      it "ensures execution resumes after the handle_event call" do
        called_count = 0
        @event_processor.handle_event(Connfu::Event::Offer.new(:from => @server_address, :to => @client_address))
        called_count = called_count + 1
        @event_processor.handle_event(Connfu::Event::SayComplete.new)
        called_count.should eql(1)
      end
    end
  end
end
