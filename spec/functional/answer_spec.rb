require "spec_helper"

describe "answering a call" do

  testing_dsl do
    on :offer do |call|
      answer
      finish!
    end
  end

  it "should check sequence" do
    check_sequence do
      @call_jid = "call-id@server.whatever"
      @client_jid = "usera@127.0.0.whatever/voxeo"

      event :offer_presence, @call_jid, @client_jid
      event :result_iq, @call_jid
      finished
    end
  end

end