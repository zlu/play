require "spec_helper"

describe "two simultaneous offers" do
  class TwoOffersExample
    include Connfu::Dsl

    on :offer do
      answer
      say 'this is the first say'
      say 'this is the second say'
    end
  end

  before :each do
    Connfu.setup "testuser@testhost", "1"
    @processor = Connfu::EventProcessor.new(TwoOffersExample)

    Connfu.adaptor = TestConnection.new

    @server_address = "34209dfiasdoaf@server.whatever"
    @foo_address = "foo@clientfoo.com"
    @bar_address = "bar@clientbar.com"
  end

  it "should handle each call independently" do
    @processor.handle_event Connfu::Event::Offer.new(:from => @server_address, :to => @foo_address, :call_id => 'foo')
    @processor.handle_event Connfu::Event::Offer.new(:from => @server_address, :to => @bar_address, :call_id => 'bar')
    @processor.handle_event Connfu::Event::SayComplete.new(:call_id => 'bar')

    Connfu.adaptor.commands = []
    @processor.handle_event Connfu::Event::SayComplete.new(:call_id => 'foo')

    Connfu.adaptor.commands.last.should == Connfu::Commands::Say.new(:text => 'this is the second say', :to => @server_address, :from => @foo_address)
  end

end
