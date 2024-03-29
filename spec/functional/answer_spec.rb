require "spec_helper"

describe "answering a call" do

  testing_dsl do
    on :offer do |call|
      answer
      do_something
    end
  end

  before :each do
    @call_jid = "call-id@server.whatever"
    @client_jid = "usera@127.0.0.whatever/voxeo"
  end

  it "should send an answer command" do
    incoming :offer_presence, @call_jid, @client_jid

    last_command.should == Connfu::Commands::Answer.new(:call_jid => @call_jid, :client_jid => @client_jid)
  end

  it "should continue to execute once the result of the answer is received" do
    dsl_instance.should_receive(:do_something)

    incoming :offer_presence, @call_jid, @client_jid
    incoming :answer_result_iq, @call_jid
  end
end