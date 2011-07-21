require 'spec_helper'

describe Connfu do
  before do
    @uri = 'jid://foo:password@bar.com'
    Connfu.setup(@uri)
    Connfu.connection = nil
    Connfu.connection
  end

  describe "#setup(uri = nil)" do
    it "should create a proxied connection to server" do
      @connection = Connfu.connection
      @connection.proxied_connection.should be_instance_of(Blather::Client)
      @connection.should be_setup
    end

    it "should register iq handler for offer" do
      iq = mock('incoming_iq')
      Connfu.event_processor = mock('event-processor', :handle_event => true)
      Connfu::Ozone::Parser.should_receive(:parse_event_from).with(iq)
      Connfu.connection.send :call_handler_for, :iq, iq
    end

    it 'should register presence handler' do
      presence = mock('presence')
      Connfu.event_processor = mock('event-processor', :handle_event => true)
      Connfu::Ozone::Parser.should_receive(:parse_event_from).with(presence)
      Connfu.connection.send :call_handler_for, :presence, presence
    end
  end

  describe "#start" do
    it "should start the EventMachine" do
      EM.should_receive(:run)
      Connfu.start(MyTestClass)
    end

    it "should process the dial queue every second" do
      EM.should_receive(:add_periodic_timer).with(1, an_instance_of(Connfu::Queue::Worker)).and_raise(StandardError)
      lambda { Connfu.start(MyTestClass) }.should raise_error(StandardError)
    end
  end

  describe 'Queue::Worker' do

    subject { Connfu::Queue::Worker.new(Connfu::Jobs::Dial.queue) }

    it "should grab the next job from the dial queue" do
      Connfu::Queue.should_receive(:reserve).with(Connfu::Jobs::Dial.queue)
      subject.call
    end

    it "should process the next job from the dial queue" do
      job = Connfu::Jobs::Dial
      job.should_receive(:perform)
      Connfu::Queue.stub(:reserve).and_return(job)
      subject.call
    end

    it 'should not error if there are no jobs to be processed' do
      Connfu::Queue.stub(:reserve).and_return(nil)
      lambda { subject.call }.should_not raise_error
    end
  end
end