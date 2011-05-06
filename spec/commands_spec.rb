require 'spec_helper'

describe Connfu::Commands do
  describe "#answer" do
    before do
      @answer = Connfu::Commands.answer
    end

    it "should be an iq of type set" do
      @answer.should be_a_kind_of Blather::Stanza::Iq
      @answer.type.should eq :set
    end

    it "should contain an namespaced answer node" do
      @answer.child.name.should eq "answer"
      p @answer.child.namespace
    end
  end
end