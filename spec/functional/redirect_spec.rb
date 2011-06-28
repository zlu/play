require "spec_helper"

describe "answer and say something on a call" do
  class RedirectExample
    include Connfu::Dsl

    on :offer do
      redirect('sip:another@connfu.com')
    end
  end

  before :each do
    Connfu.setup "testuser@testhost", "1"
    Connfu.handler_class = RedirectExample

    Connfu.adaptor = TestConnection.new

    @server_address = "34209dfiasdoaf@server.whatever"
    @client_address = "usera@127.0.0.whatever/voxeo"

    @redirect_to = 'sip:another@connfu.com'
  end

  it "should reject the call" do
    run_fake_event_loop Connfu::Event::Offer.new(:from => @server_address, :to => @client_address)

    Connfu.adaptor.commands.should == [
      Connfu::Commands::Redirect.new(:redirect_to => @redirect_to, :to => @server_address, :from => @client_address),
    ]
  end
end