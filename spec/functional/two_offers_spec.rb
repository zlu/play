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
    Connfu.event_processor = Connfu::EventProcessor.new(TwoOffersExample)

    Connfu.adaptor = TestConnection.new

    @first_server_address = "foo@server.whatever"
    @second_server_address = "bar@server.whatever"
    @foo_address = "foo@clientfoo.com"
    @bar_address = "bar@clientbar.com"
  end

  it "should handle each call independently" do
    Connfu.handle_stanza(create_stanza(offer_presence(@first_server_address, @foo_address)))
    Connfu.handle_stanza(create_iq(result_iq("foo")))
    Connfu.handle_stanza(create_iq(result_iq("foo")))

    Connfu.handle_stanza(create_stanza(offer_presence(@second_server_address, @bar_address)))
    Connfu.handle_stanza(create_iq(result_iq("bar")))
    Connfu.handle_stanza(create_iq(result_iq("bar")))

    Connfu.handle_stanza(create_stanza(say_complete_success("bar")))

    Connfu.adaptor.commands = []
    Connfu.handle_stanza(create_stanza(say_complete_success("foo")))

    Connfu.adaptor.commands.last.should == Connfu::Commands::Say.new(:text => 'this is the second say', :to => @first_server_address, :from => @foo_address)
  end

end
