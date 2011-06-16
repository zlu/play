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
        @concept = @ask_complete_iq.children.select { |n| n.name == 'complete' }.first[:concept]
        @event_node = Connfu::Event::AskComplete.import(@ask_complete_iq)
        Connfu.dsl_processor.ask_handler = {'result'=>"say((\"your input is \" + result))"}
      end

      it 'should eval ask_handler' do
        Connfu.base.should_receive(:module_eval).with("say((\"your input is \" + \"#{@concept}\"))")
        @event_node.react
      end
    end
  end

  describe Connfu::Event::OutboundResult do
    before do
      Connfu.setup('host', 'password')
      @oc_iq = Connfu::Event::OutboundResult.import(create_iq(outbound_result_iq))
      @ref_nodes = @oc_iq.children.select { |c| c.name == 'ref' }
    end

    it 'should be a kind of Iq' do
      @oc_iq.should be_kind_of Blather::Stanza::Iq
    end

    it 'should be a result iq' do
      @oc_iq.type.should eq :result
    end

    it 'should contain a to attribute' do
      @oc_iq.attributes['to'].should_not be_nil
    end

    it 'should contain a from attribute' do
      @oc_iq.attributes['from'].should_not be_nil
    end

    describe 'ref node' do
      it 'should contain only one' do
        @ref_nodes.size.should eq 1
      end

      it 'should have an id attribute' do
        @ref_nodes.first.attributes['id'].should_not be_nil
      end
    end

    describe '#self.import' do
      it 'should update outbound call context' do
        Connfu.outbound_context = {}
        lambda {
          Connfu::IqParser.parse(create_iq(outbound_result_iq))
        }.should change { Connfu.outbound_context.count }.by(1)
      end

      context 'when outbound is initiated for conference' do
        it 'should send conference iq to server' do
          Connfu.conference_handlers = ['foo']
          Connfu.connection.should_receive(:write)
          Connfu::IqParser.parse(create_iq(outbound_result_iq))
        end
      end
    end
  end

  describe 'Connfu::Event::Answered' do
    before do
      @answered = Connfu::Event::Answered.import(create_iq(answered_event_iq))
    end

    it 'should be a kind of iq' do
      @answered.should be_kind_of Blather::Stanza::Iq
    end

    it 'should contain a to attribute' do
      @answered.attributes['to'].should_not be_nil
    end

    it 'should contain a from attribute' do
      @answered.attributes['from'].should_not be_nil
    end

    it 'should contain a answered node' do
      @answered.xpath('//x:answered', 'x' => 'urn:xmpp:ozone:1').first.should_not be_nil
    end
  end
end