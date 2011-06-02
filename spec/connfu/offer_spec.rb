require 'spec_helper'

describe Connfu::Offer do
  before do
    @offer_iq = create_iq(offer_iq)
  end

  describe '#result_for_node' do
    it 'should create an empty result iq based on offer iq' do
      result_iq = Connfu::Offer.result_for_node(@offer_iq)
      result_iq.from.should eq @offer_iq.to
      result_iq.to.should eq @offer_iq.from
    end
  end

  describe "#import" do
    it 'should send an empty result iq to server' do
      #TODO figure out .with part
      Connfu.connection.should_receive(:write)#.with(Connfu::Offer.result_for_node(@offer_iq))
      Connfu::Offer.import(@offer_iq)
    end
  end
end