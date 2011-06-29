require "spec_helper"

describe "answering a call" do
  class AnswerExample
    include Connfu::Dsl

    on :offer do
      answer
    end
  end

  before :each do
    Connfu.setup "testuser@testhost", "1"
    @processor = Connfu::EventProcessor.new(AnswerExample)

    Connfu.adaptor = TestConnection.new

    @server_address = "34209dfiasdoaf@server.whatever"
    @client_address = "usera@127.0.0.whatever/voxeo"
  end

  it "should send an answer command" do
    @processor.handle_event Connfu::Event::Offer.new(:from => @server_address, :to => @client_address)

    Connfu.adaptor.commands.last.should == Connfu::Commands::Answer.new(:to => @server_address, :from => @client_address)
  end

end
