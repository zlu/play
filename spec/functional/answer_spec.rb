require "spec_helper"

describe "answering a call" do

  testing_dsl do
    on :offer do
      answer
    end
  end

  before :each do
    @server_address = "34209dfiasdoaf@server.whatever"
    @client_address = "usera@127.0.0.whatever/voxeo"
  end

  it "should send an answer command" do
    incoming :offer_presence, @server_address, @client_address

    Connfu.adaptor.commands.last.should == Connfu::Commands::Answer.new(:to => @server_address, :from => @client_address)
  end

end
