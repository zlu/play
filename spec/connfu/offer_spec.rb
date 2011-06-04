require 'spec_helper'

describe Connfu::Offer do
  before do
    EM.stub(:run)
    Connfu::start
    @offer_iq = create_iq(offer_iq)
  end

  describe '#result_for_node' do
    it 'should create an empty result iq based on offer iq' do
      result_iq = Connfu::Offer.result_for_node(@offer_iq)
      result_iq.from.should eq @offer_iq.to
      result_iq.to.should eq @offer_iq.from
      result_iq.id.should eq @offer_iq.id
    end
  end

  describe "#import" do
    before do
      Connfu.context = {}
    end

    it 'should send an empty result iq to server' do
      allow_message_expectations_on_nil
      #TODO figure out .with part
      Connfu.connection.should_receive(:write)#.with(Connfu::Offer.result_for_node(@offer_iq))
      Connfu::Offer.import(@offer_iq)
    end

    it 'should add a call context for the current call' do
      allow_message_expectations_on_nil
      Connfu.connection.stub(:write)
      lambda {
        Connfu::Offer.import(@offer_iq)
      }.should change(Connfu.context,:size).from(0).to(1)
    end

     it 'should create a valid call context for the current call' do
       allow_message_expectations_on_nil
       Connfu.connection.stub(:write)
       Connfu::Offer.import(@offer_iq)
       l.debug @offer_iq.from.to_s
       Connfu.context.keys.first.should eq @offer_iq.from.to_s.match(/(.*)@.*/)[1]
       Connfu.context.values.first.should eq @offer_iq
     end
  end
end