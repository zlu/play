require 'spec_helper'

describe Connfu::Event do
  describe Connfu::Event::SayComplete do
    describe "#import" do
      it "should call iq_parser#fire_event" do
        Connfu::IqParser.should_receive(:fire_event)
        Connfu::Event::SayComplete.import(create_iq(say_complete_iq))
      end
    end
  end

  describe Connfu::Event::Result do
    
  end
end