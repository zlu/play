require "spec_helper"

describe "Empty DSL Class" do

  testing_dsl do
  end

  before :each do
    @call_jid = "call-id@server.whatever"
    @client_jid = "usera@127.0.0.whatever/voxeo"
  end

  it "should not raise an error on offer event received" do
    lambda {
      incoming :offer_presence, @call_jid, @client_jid
    }.should_not raise_error
  end
end