require "spec_helper"

describe "ask a caller for 4 digits" do

  testing_dsl do
    on :offer do |call|
      result = ask(:prompt => "please enter a 4 digit pin", :digits => 4)
      say("you entered #{result}")
    end
  end

  it "should check sequence" do
    check_sequence do
      @call_jid = "call-id@server.whatever"
      @client_jid = "usera@127.0.0.whatever/voxeo"

      event :offer_presence, @call_jid, @client_jid
      command Connfu::Commands::Ask.new(
        :call_jid => @call_jid,
        :client_jid => @client_jid,
        :prompt => "please enter a 4 digit pin",
        :digits => 4
      )
      event :result_iq, @call_jid
      event :ask_success_presence, @call_jid, "1234"
      command Connfu::Commands::Say.new(
        :text => 'you entered 1234', :call_jid => @call_jid, :client_jid => @client_jid
      )
    end
  end
end