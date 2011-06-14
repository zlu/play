require 'spec_helper'

describe Connfu do
  describe "#setup" do
    before do
      @host = 'foo@bar.com'
      @password = 'password'
      Connfu::IqParser.stub(:parse)
      Connfu::IqParser.stub(:fire_event)
    end

    after do
      Connfu.context = nil  
      Connfu.outbound_context = nil
    end

    it "should create a connection to server" do
      Connfu.setup(@host, @password)
      @connection = Connfu.connection
      @connection.should be_instance_of(Blather::Client)
      @connection.should be_setup
    end

    it 'should initialize call context' do
      lambda {
        Connfu.setup(@host, @password)
      }.should change(Connfu, :context).from(nil).to({})
    end

    it 'should initialize outbound call context' do
      lambda {
        Connfu.setup(@host, @password)
      }.should change(Connfu, :outbound_context).from(nil).to({})
    end

    it "should register ready handler that prints out connection message" do
      Connfu.setup(@host, @password)
      Connfu.should_receive(:p).with('Established @connection to Connfu Server')
      Connfu.connection.send :call_handler_for, :ready, ''
    end

    it "should register iq handler for offer" do
      iq = mock('incoming_iq')
      Connfu.setup(@host, @password)
      Connfu::IqParser.should_receive(:parse).with(iq)
      Connfu.connection.send :call_handler_for, :iq, iq
    end
  end

  describe "#start" do
    it "should start the EventMachine" do
      EM.should_receive(:run)
      Connfu.start
    end
  end
end