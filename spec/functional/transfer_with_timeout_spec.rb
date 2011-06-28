require "spec_helper"

describe "a timeout occurs when attempting to transfer a call" do
  class TransferWithTimeoutExample
    include Connfu::Dsl

    on :offer do
      answer
      say('hello, this is connfu, please wait to be transferred')
      if transfer('sip:userb@127.0.0.1')
        say('transfer was successful')
      else
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

  it "should attempt to transfer the call" do
    run_fake_event_loop Connfu::Event::Offer.new(:from => @server_address, :to => @client_address),
                        Connfu::Event::SayComplete.new

    Connfu.adaptor.commands.last.should == Connfu::Commands::Transfer.new(:transfer_to => ['sip:userb@127.0.0.1'], :to => @server_address, :from => @client_address)
  end

  it "should indicate that the call has been transferred successfully" do
    run_fake_event_loop Connfu::Event::Offer.new(:from => @server_address, :to => @client_address),
                        Connfu::Event::SayComplete.new,
                        Connfu::Event::TransferSuccess.new

    Connfu.adaptor.commands.last.should == Connfu::Commands::Say.new(:text => 'transfer was successful', :to => @server_address, :from => @client_address)
  end

  it "should indicate that the call transfer has been timed out" do
    run_fake_event_loop Connfu::Event::Offer.new(:from => @server_address, :to => @client_address),
                        Connfu::Event::SayComplete.new,
                        Connfu::Event::TransferTimeout.new

    Connfu.adaptor.commands.last.should == Connfu::Commands::Say.new(:text => 'sorry nobody is available at the moment', :to => @server_address, :from => @client_address)
  end
end
