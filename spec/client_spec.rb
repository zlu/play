require 'spec_helper'

describe Connfu::Client do
  describe "#initialize" do
    it "should create a connection to xmpp server" do
      Blather::Client.should_receive(:setup).with(Credentials::CLIENT_JID, Credentials::CLIENT_PWD)
      Connfu::Client.new
    end
  end
end