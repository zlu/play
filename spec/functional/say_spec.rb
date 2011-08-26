require "spec_helper"

describe "say something on a call" do

  testing_dsl do
    on :offer do |call|
      say('hello, this is connfu')
      say('http://www.phono.com/audio/troporocks.mp3')
    end
  end

  let(:actor) { Actor.new("James Adam <sip:james@127.0.0.1>") }

  it "should send first say command" do
    Connfu.connection.pause_after :offer_presence

    actor.call

    last_command.should == Connfu::Commands::Say.new(:text => 'hello, this is connfu', :call_jid => actor.call_jid, :client_jid => actor.client_jid)
  end

  it "should not send the second say command if the first command's success hasn't been received" do
    Connfu.connection.pause_after :say_result_iq

    actor.call

    last_command.should == Connfu::Commands::Say.new(:text => 'hello, this is connfu', :call_jid => actor.call_jid, :client_jid => actor.client_jid)
  end

  it "should send the second say command once the first say command has completed" do
    Connfu.connection.pause_after :say_success_presence

    actor.call

    last_command.should == Connfu::Commands::Say.new(:text => 'http://www.phono.com/audio/troporocks.mp3', :call_jid => actor.call_jid, :client_jid => actor.client_jid)
  end
end

describe "stopping a say command" do
  testing_dsl do
    on :offer do |call|
      answer
      send_command Connfu::Commands::Say.new(:text => 'hello world', :call_jid => call_jid, :client_jid => client_jid)
      dial :to => "anyone", :from => "anyone else"
      send_command Connfu::Commands::Stop.new(:component_id => 'say-component-id', :call_jid => call_jid, :client_jid => client_jid)
    end
  end

  let(:actor) { Actor.new("James Adam <sip:james@127.0.0.1>") }

  it 'should send the stop command to an active say component' do
    Connfu.connection.dont_send :say_success_presence
    Connfu.connection.pause_after :dial_result_iq

    actor.call

    last_command.should == Connfu::Commands::Stop.new(:component_id => 'say-component-id', :call_jid => actor.call_jid, :client_jid => actor.client_jid)
  end

  it 'should not send the stop command if the say component has already finished' do
    actor.call

    last_command.should_not be_instance_of(Connfu::Commands::Stop)
  end
end