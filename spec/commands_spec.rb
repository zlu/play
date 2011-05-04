require 'spec_helper'

describe Connfu::Commands do

  describe "#answer" do
    before do
      @client = Blather::Client.new
      p @client
      @stanza = Blather::Stanza::Iq.new
      response = mock()
      response.stub(:call)
      @client.register_handler(:iq) { |_| response.call }
    end

    it "should be able to answer an offer with a successful result" do
      @client.should_receive(:answer)
      @client.receive_data(@stanza)
    end
  end
end