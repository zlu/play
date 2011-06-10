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

    it "should register ready handler that prints out connection message" do
      pending 'need access to handlers and their associated block'
      l.debug @connection.send :current_handlers
      Connfu.setup(@host, @password)
      ready_handler = @connection.send :current_handlers[:ready]
      ready_handler[0][0].should_not be_nil
      ready_proc = ready_handler[0][0][0]
      ready_proc.should be_instance_of(Proc)
      Connfu.should_receive(:p).with('Established @connection to Connfu Server')
      ready_proc.call
    end

    it "should register iq handler for offer" do
      pending 'need access to handlers and their associated block'
      Connfu.setup(@host, @password)
      iq_handler = @connection.send :current_handlers[:iq]
      iq_proc = iq_handler[0][1]
      iq_proc.should be_instance_of(Proc)
      iq_proc.call
    end
  end

  describe "#start" do
    it "should start the EventMachine" do
      EM.should_receive(:run)
      Connfu.start
    end
  end

  describe "examples" do
    it "should parse all examples" do
      pending
      l.debug str = File.open('../examples/answer_example.rb').readlines.join
      l.debug Connfu::DslProcessor.new.process(ParseTree.new.parse_tree_for_string(str)[0])
    end
  end
end