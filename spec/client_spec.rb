require 'spec_helper'

describe Connfu::Client do
  describe "#initialize" do
    it "should create a connection to xmpp server" do
      Blather::Client.should_receive(:setup)
      Connfu::Client.new
    end
  end
end