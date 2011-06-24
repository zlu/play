require "spec_helper"

class TestConnection
  attr_reader :commands

  def initialize
    @commands = []
  end
  def send_command(command)
    @commands << command
  end
end

describe "answering a call" do
  class AnswerExample
    include Connfu::Dsl

    on :offer do
      answer
      say('hello, this is connfu')
      say('http://www.phono.com/audio/troporocks.mp3')
    end
  end

  before :each do
    Connfu.setup "testuser@testhost", "1"
    Connfu.handler_class = AnswerExample

    Connfu.adaptor = TestConnection.new

    @server_address = "34209dfiasdoaf@server.whatever"
    @client_address = "usera@127.0.0.whatever/voxeo"
  end

  it "should answer the incoming call" do
    run_fake_event_loop Connfu::Event::Offer.new(:from => @server_address, :to => @client_address)

    Connfu.adaptor.commands.should == [
      Connfu::Commands::Answer.new(:to => @server_address, :from => @client_address),
    ]
  end

  it "should send the first say command once the answer has been acknowledged" do
    run_fake_event_loop Connfu::Event::Offer.new(:from => @server_address, :to => @client_address),
                        Connfu::Event::Result.new

    Connfu.adaptor.commands.should == [
      Connfu::Commands::Answer.new(:to => @server_address, :from => @client_address),
      Connfu::Commands::Say.new(:text => 'hello, this is connfu', :to => @server_address)
    ]
  end

  it "should send the second say command once the first say command has completed" do
    run_fake_event_loop Connfu::Event::Offer.new(:from => @server_address, :to => @client_address),
                        Connfu::Event::Result.new,
                        Connfu::Event::Result.new,
                        Connfu::Event::SayComplete.new

    Connfu.adaptor.commands.should == [
      Connfu::Commands::Answer.new(:to => @server_address, :from => @client_address),
      Connfu::Commands::Say.new(:text => 'hello, this is connfu', :to => @server_address),
      Connfu::Commands::Say.new(:text => 'http://www.phono.com/audio/troporocks.mp3', :to => @server_address)
    ]
  end

  def run_fake_event_loop(*events, &block)
    while event = events.shift do
      catch :waiting do
        Connfu::IqParser.handle_event event
      end
    end
  end

end
