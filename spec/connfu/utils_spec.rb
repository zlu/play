require 'spec_helper'

describe Connfu::Utils do
  describe "#disco_items" do
    it "should send DiscoItems iq to server" do
      Connfu::Utils.should_receive(:write_to_stream).once.with(an_instance_of(Blather::Stanza::DiscoItems))
      Connfu::Utils.disco_items
    end
  end

  describe "#disco_info" do
    it "should send DiscoInfo iq to server" do
      identity = "foo_identity"
      Connfu::Utils.should_receive(:write_to_stream).once.with(an_instance_of(Blather::Stanza::DiscoInfo))
      Connfu::Utils.disco_info(identity)
    end
  end
end