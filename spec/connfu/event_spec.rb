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

  describe Connfu::Event::AskComplete do
    describe '#react' do
      before do
        @ask_complete_iq = create_iq(complete_for_ask_iq)
        @concept = @ask_complete_iq.children.select{|n| n.name == 'complete'}.first[:concept]
        @event_node = Connfu::Event::AskComplete.import(@ask_complete_iq)
        Connfu.dsl_processor.ask_handler = {'result'=>"say((\"your input is \" + result))"}
      end

      it 'should eval ask_handler' do
        l.debug @event_node
        l.debug Connfu.dsl_processor.ask_handler
        l.debug @concept.class.name
        Connfu.base.should_receive(:module_eval).with("say((\"your input is \" + \"#{@concept}\"))")
        @event_node.react
      end
    end
  end
end