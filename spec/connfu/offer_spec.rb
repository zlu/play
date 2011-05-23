require 'spec_helper'

describe Connfu::Offer do
  context "when offer comes from Prism" do
    before do
      @offer = Connfu::Offer.create_from_iq(offer_iq)
    end

    it "should contain an offer node" do
      @offer.children[1].name.should eq "offer"
    end

    it "should be an instance of Offer" do
      @offer.should be_instance_of(Connfu::Offer)
    end

    it "should create a ringing event" do
      
    end
  end
end

