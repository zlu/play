require "spec_helper"

describe "hangup a call" do
  class HangupExample
    include Connfu::Dsl

    on :offer do
      hangup
    end
  end

  before :each do
    setup_connfu HangupExample

    @server_address = "34209dfiasdoaf@server.whatever"
    @client_address = "usera@127.0.0.whatever/voxeo"
  end

  it "should send the hangup command" do
    incoming :offer_presence, @server_address, @client_address

    Connfu.adaptor.commands.last.should == Connfu::Commands::Hangup.new(:to => @server_address, :from => @client_address)
  end
end
