require 'spec_helper'

describe Connfu do
  describe "#setup" do
    before do
      @host = 'foo@bar.com'
      @password = 'password'
      @connection = Connfu.setup(@host, @password)
    end

    it "should create a connection to server" do
      @connection.should be_instance_of(Blather::Client)
      @connection.should be_setup
    end

    it "should setup the stream" do
      pending "Need to figure out how to post_init stream correctly"
      @connection.post_init(mock('stream'), Blather::JID.new('me.com'))
      @connection.send(:stream).should_not be_nil
    end

    it "should register ready handler that prints out connection message" do
      ready_handler = @connection.handlers[:ready]
      ready_handler[0][0].should_not be_nil
      ready_proc = ready_handler[0][0][0]
      ready_proc.should be_instance_of(Proc)
      Connfu.should_receive(:p).with('Established connection to Connfu Server')
      ready_proc.call
    end

    it "should register iq handler for offer" do
      iq_handler = @connection.handlers[:iq]
      iq_handler[0][0][0].should eq 'iq/offer'
      iq_handler[0][0][1][:ns].should eq 'urn:xmpp:ozone:1'
      iq_proc = iq_handler[0][1]
      iq_proc.should be_instance_of(Proc)
      Connfu.should_receive(:p).with('Start to handle incoming offer')
      iq_proc.call
    end
  end
end