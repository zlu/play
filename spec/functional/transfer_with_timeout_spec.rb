require "spec_helper"

describe "a timeout occurs when attempting to transfer a call" do
  class TransferWithTimeoutExample
    include Connfu::Dsl

    on :offer do
      answer
      say('hello, this is connfu, please wait to be transferred')
      unless transfer('sip:userb@127.0.0.1')
        say('sorry nobody is available at the moment')
      end
    end
  end

  before :each do
    @server_address = "34209dfiasdoaf@server.whatever"
    @client_address = "usera@127.0.0.whatever"
    Connfu.setup "@client_address", "1"
    Connfu.handler_class = TransferWithTimeoutExample

    Connfu.adaptor = TestConnection.new
  end

  it "should indicate that the call has been timed out" do
    run_fake_event_loop Connfu::Event::Offer.new(:from => @server_address, :to => @client_address),
                        Connfu::Event::SayComplete.new,
                        Connfu::Event::Timeout.new

    Connfu.adaptor.commands.should == [
      Connfu::Commands::Answer.new(:to => @server_address, :from => @client_address),
      Connfu::Commands::Say.new(:text => 'hello, this is connfu, please wait to be transferred', :to => @server_address, :from => @client_address),
      Connfu::Commands::Transfer.new(:transfer_to => ['sip:userb@127.0.0.1'], :to => @server_address, :from => @client_address),
      Connfu::Commands::Say.new(:text => 'sorry nobody is available at the moment', :to => @server_address, :from => @client_address)
    ]
  end
end
