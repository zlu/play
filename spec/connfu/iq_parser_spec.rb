require 'spec_helper'

include Connfu::IqParser

describe Connfu::IqParser do
  describe "#parse" do
    it "should create an offer for offer iq" do
      offer = Connfu::IqParser.parse(offer_iq)
      offer.should be_instance_of Connfu::Offer
      offer.id.should eq offer_iq.match(/.*id='(.*)'\sfrom=.*/)[1]
    end

    it "should create an error for error iq" do
      error = Connfu::IqParser.parse(error_iq)
      error.should be_instance_of Connfu::Error
      error.id.should eq error_iq.match(/.*id='(.*)'\sfrom=.*/)[1]
    end
  end
end