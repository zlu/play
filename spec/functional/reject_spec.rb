require "spec_helper"

describe "a call reject" do
  class RejectExample
    include Connfu::Dsl

    on :offer do
      reject
    end
  end

  before :each do
    Connfu.setup "testuser@testhost", "1"
    Connfu.handler_class = RejectExample

    Connfu.adaptor = TestConnection.new

    @server_address = "34209dfiasdoaf@server.whatever"
    @client_address = "usera@127.0.0.whatever/voxeo"
  end

  it "should send the reject command" do
    run_fake_event_loop Connfu::Event::Offer.new(:from => @server_address, :to => @client_address)

    Connfu.adaptor.commands.last.should == Connfu::Commands::Reject.new(:to => @server_address, :from => @client_address)
  end
end
