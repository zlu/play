require "spec_helper"

describe "say something on a call" do
  class SayExample
    include Connfu::Dsl

    on :offer do
      say('hello, this is connfu')
      say('http://www.phono.com/audio/troporocks.mp3')
    end
  end

  before :each do
    Connfu.setup "testuser@testhost", "1"
    @processor = Connfu::EventProcessor.new(SayExample)

    Connfu.adaptor = TestConnection.new

    @server_address = "34209dfiasdoaf@server.whatever"
    @client_address = "usera@127.0.0.whatever/voxeo"
  end

  it "should send first say command" do
    @processor.handle_event Connfu::Event::Offer.new(:from => @server_address, :to => @client_address)
    Connfu.adaptor.commands.last.should == Connfu::Commands::Say.new(:text => 'hello, this is connfu', :to => @server_address, :from => @client_address)
  end

  it "should send the second say command once the first say command has completed" do
    @processor.handle_event Connfu::Event::Offer.new(:from => @server_address, :to => @client_address)
    @processor.handle_event Connfu::Event::SayComplete.new

    Connfu.adaptor.commands.last.should == Connfu::Commands::Say.new(:text => 'http://www.phono.com/audio/troporocks.mp3', :to => @server_address, :from => @client_address)
  end
end
