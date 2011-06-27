require 'spec_helper'

describe Connfu do
  describe "#setup" do
    before do
      @host = 'foo@bar.com'
      @password = 'password'
      Connfu.setup(@host, @password)
    end

    it "should create a connection to server" do
      @connection = Connfu.connection
      @connection.should be_instance_of(Blather::Client)
      @connection.should be_setup
    end

    it "should register ready handler that prints out connection message" do
      Connfu.should_receive(:p).with('Established @connection to Connfu Server')
      Connfu.connection.send :call_handler_for, :ready, ''
    end

    it "should register iq handler for offer" do
      iq = mock('incoming_iq')
      Connfu::Ozone::Parser.should_receive(:parse_event_from).with(iq)
      Connfu.connection.send :call_handler_for, :iq, iq
    end

    it 'should register presence handler' do
      presence = mock('presence')
      Connfu::Ozone::Parser.should_receive(:parse_event_from).with(presence)
      Connfu.connection.send :call_handler_for, :presence, presence
    end
  end

  describe "#start" do
    it "should start the EventMachine" do
      EM.should_receive(:run)
      Connfu.start(MyTestClass)
    end
  end
end