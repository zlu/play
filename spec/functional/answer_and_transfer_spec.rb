require "spec_helper"

describe "answer and transfer a call" do
  class AnswerAndTransferExample
    include Connfu::Dsl

    on :offer do
      answer
      say('hello, this is connfu, please wait to be transferred')
      transfer('sip:userb@127.0.0.1')
    end
  end

  before :each do
    @server_address = "34209dfiasdoaf@server.whatever"
    @client_address = "usera@127.0.0.whatever"
    Connfu.setup "@client_address", "1"
    Connfu.handler_class = AnswerAndTransferExample

    Connfu.adaptor = TestConnection.new
  end

  it "should answer the call and say the first line" do
    run_fake_event_loop Connfu::Event::Offer.new(:from => @server_address, :to => @client_address)

    Connfu.adaptor.commands.should == [
      Connfu::Commands::Answer.new(:to => @server_address, :from => @client_address),
      Connfu::Commands::Say.new(:text => 'hello, this is connfu, please wait to be transferred', :to => @server_address, :from => @client_address)
    ]
  end

  it "should send the transfer command once the say command has completed" do
    run_fake_event_loop Connfu::Event::Offer.new(:from => @server_address, :to => @client_address),
                        Connfu::Event::SayComplete.new

    Connfu.adaptor.commands.should == [
      Connfu::Commands::Answer.new(:to => @server_address, :from => @client_address),
      Connfu::Commands::Say.new(:text => 'hello, this is connfu, please wait to be transferred', :to => @server_address, :from => @client_address),
      Connfu::Commands::Transfer.new(:transfer_to => ['sip:userb@127.0.0.1'], :to => @server_address, :from => @client_address)
    ]
  end
end
