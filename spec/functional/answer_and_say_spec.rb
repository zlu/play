require "spec_helper"

describe "answer and say something on a call" do
  class AnswerAndSayExample
    include Connfu::Dsl

    on :offer do
      answer
      say('hello, this is connfu')
      say('http://www.phono.com/audio/troporocks.mp3')
    end
  end

  before :each do
    Connfu.setup "testuser@testhost", "1"
    Connfu.handler_class = AnswerAndSayExample

    Connfu.adaptor = TestConnection.new

    @server_address = "34209dfiasdoaf@server.whatever"
    @client_address = "usera@127.0.0.whatever/voxeo"
  end

  it "should answer the call and say the first line" do
    run_fake_event_loop Connfu::Event::Offer.new(:from => @server_address, :to => @client_address)

    Connfu.adaptor.commands.should == [
      Connfu::Commands::Answer.new(:to => @server_address, :from => @client_address),
      Connfu::Commands::Say.new(:text => 'hello, this is connfu', :to => @server_address, :from => @client_address)
    ]
  end

  it "should send the second say command once the first say command has completed" do
    run_fake_event_loop Connfu::Event::Offer.new(:from => @server_address, :to => @client_address),
                        Connfu::Event::SayComplete.new

    Connfu.adaptor.commands.should == [
      Connfu::Commands::Answer.new(:to => @server_address, :from => @client_address),
      Connfu::Commands::Say.new(:text => 'hello, this is connfu', :to => @server_address, :from => @client_address),
      Connfu::Commands::Say.new(:text => 'http://www.phono.com/audio/troporocks.mp3', :to => @server_address, :from => @client_address)
    ]
  end
end
