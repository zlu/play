require 'spec_helper'

include Connfu::OutboundCall

describe Connfu::Event do
  describe Connfu::Event::SayComplete do
    describe "#import" do
      it "should call iq_parser#fire_event" do
        Connfu::IqParser.should_receive(:fire_event)
        Connfu::Event::SayComplete.import(create_iq(say_complete_success))
      end
    end
  end

  describe Connfu::Event::AskComplete do
    describe '#react' do
      before do
        @ask_complete_iq = create_stanza(ask_complete_success)
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

    describe 'to attribute' do
      before do
        @to = @oc_iq.attributes['to']
      end

      it 'should not be nil' do
        @to.should_not be_nil
      end
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
    end
  end

  describe 'Connfu::Event::Ringing' do
    before do
      @ringing_stanza = create_stanza(ringing_event)
      @from = @ringing_stanza.attributes['from'].value
      dial(@from)
      @ringing = Connfu::Event::Ringing.import(@ringing_stanza)
    end

    it 'should be a kind of iq' do
      @ringing.should be_kind_of Blather::Stanza::Iq
    end

    it 'should contain a to attribute' do
      @ringing.attributes['to'].should_not be_nil
    end

    it 'should contain a from attribute' do
      @ringing.attributes['from'].should_not be_nil
    end

    it 'should contain a answered node' do
      @ringing.xpath('//x:ringing', 'x' => 'urn:xmpp:ozone:1').first.should_not be_nil
    end

    describe '#import' do
      before do
        Connfu.outbound_calls[@from].state = nil
      end

      it 'should update current_call status' do
        lambda {
          Connfu::Event::Ringing.import(@ringing_stanza)
        }.should change{Connfu.outbound_calls[@from].state}.to(:ringing)
      end
    end
  end

  describe 'Connfu::Event::Answered' do
    before do
      Connfu.conference_handlers = []
      Connfu.connection.stub(:write)
      @answered = Connfu::Event::Answered.import(create_stanza(answered_event))
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

    describe '#self.import' do
      it 'should send conference iq with correct call_id to server' do
        Connfu.connection.unstub(:write)
        conference_iq = create_iq(spec_conference_iq)
        Connfu.conference_handlers = [conference_iq]
        Connfu.outbound_context = {'call_idxxyy' => ''}
        Connfu.connection.should_receive(:write).with(/call_idxxyy/)
        Connfu::IqParser.parse(Connfu::IqParser.parse(create_stanza(answered_event)))
      end
    end
  end
end