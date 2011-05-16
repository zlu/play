require 'spec_helper'

describe Connfu do
  describe "#setup" do
    before do
      @host = 'foo@bar.com'
      @password = 'password'
      EM.stub(:run)
    end

    it "should create a connection to server" do
      @connection = Connfu.setup(@host, @password)
      @connection.should be_instance_of(Blather::Client)
      @connection.should be_setup
    end

    it "should setup the stream" do
      pending "Need to figure out how to post_init stream correctly"
      @connection = Connfu.setup(@host, @password)
      @connection.post_init(mock('stream'), Blather::JID.new('me.com'))
      @connection.send(:stream).should_not be_nil
    end

    it "should register ready handler that prints out connection message" do
      @connection = Connfu.setup(@host, @password)
      ready_handler = @connection.handlers[:ready]
      ready_handler[0][0].should_not be_nil
      ready_proc = ready_handler[0][0][0]
      ready_proc.should be_instance_of(Proc)
      Connfu.should_receive(:p).with('Established connection to Connfu Server')
      ready_proc.call
    end

    it "should register iq handler for offer" do
      @connection = Connfu.setup(@host, @password)
      iq_handler = @connection.handlers[:iq]
      iq_proc = iq_handler[0][1]
      iq_proc.should be_instance_of(Proc)
      p iq_proc.call
    end

    it "should start the EventMachine" do
      EM.should_receive(:run)
      @connection = Connfu.setup(@host, @password)
    end
  end
end