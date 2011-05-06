require 'spec_helper'

describe Connfu::Commands do
  describe "#answer" do
    before do
      @offer = create_offer
      @answer = Connfu::Commands.answer(@offer.from.to_s)
    end

    it "should be an iq of type set" do
      @answer.should be_a_kind_of Blather::Stanza::Iq
      @answer.type.should eq :set
    end

    it "should contain a to attribute whose value is the from attribute of offer" do
      @answer.to.should_not be_nil
      @answer.to.should eq @offer.from
    end

    it "should contain an namespaced answer node" do
      @answer.child.name.should eq "answer"
      @answer.children.first.namespace.href.should eq "urn:xmpp:ozone:1"
    end
  end
end