require "spec_helper"

describe "dialing a number" do
  class Dialler
    include Connfu::Dsl

    class << self
      def do_something(call_id=nil)
        @did_something = true
        @call_id = call_id
      end
      attr_reader :did_something, :call_id

      def execute
        dial :to => "recipient", :from => "caller" do |call|
          call.on_start { Dialler.do_something(call_id) }
        end
      end
    end
  end

  before do
    setup_connfu(handler_class = nil)
  end

  it "should send a dial command" do
    Dialler.execute
    Connfu.connection.commands.last.should == Connfu::Commands::Dial.new(:to => "recipient", :from => "caller", :client_jid => Connfu.connection.jid.to_s, :rayo_host => Connfu.connection.jid.domain)
  end

  it "should not execute on_start block before command result is received" do
    Dialler.execute
    Dialler.should_not_receive(:do_something)
  end

  it "should execute on_start block after command result is received" do
    Dialler.execute
    incoming :outgoing_call_result_iq, "anything", Connfu.connection.commands.last.id
    Dialler.did_something.should be_true
  end

  it "should make the call id available when the on_start block is triggered" do
    Dialler.execute
    incoming :outgoing_call_result_iq, "call-id", Connfu.connection.commands.last.id
    Dialler.call_id.should == "call-id"
  end

end

describe "dialing with instance-specific call behaviour" do
  class DiallerWithInstanceSpecificBehaviour
    include Connfu::Dsl

    class << self
      def execute(instance_specific_argument)
        dial :to => "recipient", :from => "caller" do |call|
          call.on_answer { say instance_specific_argument }
        end
      end
    end
  end

  before do
    setup_connfu(handler_class = nil)
  end

  it "should retain the specific behaviour for each dial statement" do
    DiallerWithInstanceSpecificBehaviour.execute "first behaviour"
    first_dial_command_id = Connfu.connection.commands.last.id
    DiallerWithInstanceSpecificBehaviour.execute "second behaviour"

    incoming :outgoing_call_result_iq, "call-1", first_dial_command_id
    incoming :outgoing_call_ringing_presence, "call-1"
    incoming :outgoing_call_answered_presence, "call-1"

    Connfu.connection.commands.last.should be_instance_of Connfu::Commands::Say
    Connfu.connection.commands.last.text.should == "first behaviour"
  end
end