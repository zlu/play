require 'spec_helper'

describe Connfu::Offer do
  before do
    @offer = create_stanza(offer_presence)
  end

  describe '#result_for_node' do
    it 'should create an empty result iq based on offer iq' do
      result_iq = Connfu::Offer.result_for_node(@offer)
      result_iq.from.should eq @offer.to
      result_iq.to.should eq @offer.from
    end
  end

  describe "#import" do
    before do
      Connfu.context = {}
    end

    it 'should send an empty result iq to server' do
      allow_message_expectations_on_nil
      #TODO figure out .with part
      Connfu.connection.should_receive(:write)#.with(Connfu::Offer.result_for_node(@offer))
      Connfu::Offer.import(@offer)
    end

    it 'should add a call context for the current call' do
      allow_message_expectations_on_nil
      Connfu.connection.stub(:write)
      lambda {
        Connfu::Offer.import(@offer)
      }.should change(Connfu.context,:size).from(0).to(1)
    end

     it 'should create a valid call context for the current call' do
       allow_message_expectations_on_nil
       Connfu.connection.stub(:write)
       Connfu::Offer.import(@offer)
       Connfu.context.keys.first.should eq @offer.from.to_s.match(/(.*)@.*/)[1]
       Connfu.context.values.first.should eq @offer
     end
  end
end