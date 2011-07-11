require 'spec_helper'

class TestBaseConnection
  attr_accessor :handlers
  def initialize
    @handlers = {}
  end

  def register_handler(name, &block)
    @handlers[name] = block
  end

  def jid
    Blather::JID.new('zlu', 'openvoice.org', '1')
  end
end

module ConnectionTestingDsl
  def testing_connection_dsl(&block)
    Connfu.connection = TestBaseConnection.new
    dsl_class = Class.new
    dsl_class.send(:include, Connfu::Dsl)
    dsl_class.class_eval(&block)
    before(:each) {
      Connfu.event_processor = Connfu::EventProcessor.new(dsl_class)
      Connfu.adaptor = TestConnection.new
    }
    let(:dsl_instance) { dsl_class.any_instance }
  end
end

RSpec.configure do |config|
  config.extend ConnectionTestingDsl
end

describe "Dialing a single number" do
  testing_connection_dsl do
    dial :to => "someone-remote", :from => "my-number"
  end

  it "should send set the ready connection handler with a dial command" do
    Connfu.connection.handlers[:ready].call
    Connfu.adaptor.commands.last.should == Connfu::Commands::Dial.new(:to => 'someone-remote', :from => "my-number")
  end
end