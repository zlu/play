require 'spec_helper'

describe Connfu::Offer do
  before do
    @offer = Connfu::Offer.new
  end

  it "should be an iq stanza" do
    @offer.should be_a_kind_of Blather::Stanza::Iq
    @offer.registered_name.should eq "iq"
  end

  it "should be a type set" do
    @offer.type.should eq :set
  end

  context "when offer comes from Prism" do
    it "should contain an offer node" do
      @offer = create_offer
      @offer.children[1].name.should eq "offer"
    end
  end
end

