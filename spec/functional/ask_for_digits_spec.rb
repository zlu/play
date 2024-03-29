require "spec_helper"

describe "ask a caller for 4 digits" do

  testing_dsl do
    on :offer do |call|
      answer
      result = ask(:prompt => "please enter a 4 digit pin", :digits => 4)
      say("you entered #{result}")
    end
  end

  before :each do
    @call_jid = "call-id@server.whatever"
    @client_jid = "usera@127.0.0.whatever/voxeo"
  end

  it "should send an ask command" do
    incoming :offer_presence, @call_jid, @client_jid
    incoming :answer_result_iq, @call_jid

    last_command.should == Connfu::Commands::Ask.new(
      :call_jid => @call_jid,
      :client_jid => @client_jid,
      :prompt => "please enter a 4 digit pin",
      :digits => 4
    )
  end

  it "should continue when ask was successful" do
    incoming :offer_presence, @call_jid, @client_jid
    incoming :answer_result_iq, @call_jid
    incoming :ask_result_iq, @call_jid
    incoming :ask_success_presence, @call_jid, "1234"

    last_command.should == Connfu::Commands::Say.new(
      :text => 'you entered 1234', :call_jid => @call_jid, :client_jid => @client_jid
    )
  end
end