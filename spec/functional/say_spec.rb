require "spec_helper"

describe "say something on a call" do

  testing_dsl do
    on :offer do |call|
      say('hello, this is connfu')
      say('http://www.phono.com/audio/troporocks.mp3')
    end
  end

  it "should check sequence" do
    check_sequence do
      @call_id = "call-id"
      @call_jid = "#{@call_id}@server.whatever"
      @client_jid = "usera@127.0.0.whatever/voxeo"

      event :offer_presence, @call_jid, @client_jid
      command Connfu::Commands::Say.new(:text => 'hello, this is connfu', :call_jid => @call_jid, :client_jid => @client_jid)
      event :result_iq, @call_jid
      event :say_success_presence, @call_jid
      command Connfu::Commands::Say.new(:text => 'http://www.phono.com/audio/troporocks.mp3', :call_jid => @call_jid, :client_jid => @client_jid)
    end
  end
end