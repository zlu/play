require "spec_helper"

describe "two simultaneous offers" do

  testing_dsl do
    on :offer do |call|
      answer
      say 'this is the first say'
      say 'this is the second say'
    end
  end

  before :each do
    @first_call_jid = "foo@server.whatever"
    @second_call_jid = "bar@server.whatever"
    @foo_address = "foo@clientfoo.com"
    @bar_address = "bar@clientbar.com"
  end

  it "should handle each call independently" do
    incoming :offer_presence, @first_call_jid, @foo_address
    incoming :result_iq, @first_call_jid
    incoming :result_iq, @first_call_jid

    incoming :offer_presence, @second_call_jid, @bar_address
    incoming :result_iq, @second_call_jid
    incoming :result_iq, @second_call_jid

    incoming :say_complete_success, "bar"
    Connfu.connection.commands = []
    incoming :say_complete_success, "foo"

    last_command.should == Connfu::Commands::Say.new(:text => 'this is the second say', :call_jid => @first_call_jid, :client_jid => @foo_address)
  end

end
