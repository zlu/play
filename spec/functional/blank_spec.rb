require "spec_helper"

describe "Empty DSL Class" do

  testing_dsl do
  end

  before :each do
    @call_jid = "123@server.whatever"
    @client_address = "usera@127.0.0.whatever/voxeo"
  end

  it "should not raise an error on offer event recieved" do
    lambda {
      incoming :offer_presence, @call_jid, @client_address
    }.should_not raise_error
  end
end