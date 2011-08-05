require "spec_helper"

describe "a call redirect" do

  testing_dsl do
    on :offer do |call|
      redirect('sip:another@connfu.com')
    end
  end

  before :each do
    @call_jid = "34209dfiasdoaf@server.whatever"
    @client_address = "usera@127.0.0.whatever/voxeo"

    @redirect_to = 'sip:another@connfu.com'
  end

  it "should send the redirect command" do
    incoming :offer_presence, @call_jid, @client_address

    Connfu.connection.commands.last.should == Connfu::Commands::Redirect.new(:redirect_to => @redirect_to, :call_jid => @call_jid, :from => @client_address)
  end
end
