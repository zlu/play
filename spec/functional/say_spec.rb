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
    Connfu.event_processor = Connfu::EventProcessor.new(SayExample)

    Connfu.adaptor = TestConnection.new

    @call_id = "34209dfiasdoaf"
    @server_address = "#{@call_id}@server.whatever"
    @client_address = "usera@127.0.0.whatever/voxeo"
  end

  it "should send first say command" do
    incoming :offer_presence, @server_address, @client_address

    Connfu.adaptor.commands.last.should == Connfu::Commands::Say.new(:text => 'hello, this is connfu', :to => @server_address, :from => @client_address)
  end

  it "should send the second say command once the first say command has completed" do
    incoming :offer_presence, @server_address, @client_address
    incoming :result_iq, @call_id
    incoming :say_complete_success, @call_id

    Connfu.adaptor.commands.last.should == Connfu::Commands::Say.new(:text => 'http://www.phono.com/audio/troporocks.mp3', :to => @server_address, :from => @client_address)
  end
end
