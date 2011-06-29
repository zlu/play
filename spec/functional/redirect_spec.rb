require "spec_helper"

describe "a call redirect" do
  class RedirectExample
    include Connfu::Dsl

    on :offer do
      redirect('sip:another@connfu.com')
    end
  end

  before :each do
    Connfu.setup "testuser@testhost", "1"
    @processor = Connfu::EventProcessor.new(RedirectExample)

    Connfu.adaptor = TestConnection.new

    @server_address = "34209dfiasdoaf@server.whatever"
    @client_address = "usera@127.0.0.whatever/voxeo"

    @redirect_to = 'sip:another@connfu.com'
  end

  it "should send the redirect command" do
    @processor.handle_event Connfu::Event::Offer.new(:from => @server_address, :to => @client_address)

    Connfu.adaptor.commands.last.should == Connfu::Commands::Redirect.new(:redirect_to => @redirect_to, :to => @server_address, :from => @client_address)
  end
end
