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

    it "should register ready handler" do
      pending
    end
  end
end