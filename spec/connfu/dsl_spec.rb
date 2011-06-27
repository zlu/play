require 'spec_helper'

describe Connfu::Dsl do
  class DslTest
    include Connfu::Dsl
  end

  subject {
    DslTest.new(:from => "server-address", :to => "client-address")
  }

  describe 'say' do
    it 'should send Say command to adaptor' do
      allow_message_expectations_on_nil
      text = 'connfu is awesome'
      catch :waiting do
        Connfu.adaptor.should_receive(:send_command).with(Connfu::Commands::Say.new(:text => text, :from => 'client-address', :to => 'server-address'))
        subject.say(text)
      end
    end
  end

  describe "answer" do
    before do
      Connfu.adaptor = mock('connection_adaptor')
      Connfu.adaptor.stub(:send_command)
    end

    it "should not call wait" do
      subject.should_not_receive(:wait)
      subject.answer
    end
  end

  describe 'hangup' do
    it 'should send Hangup command to adaptor' do
      Connfu.adaptor.should_receive(:send_command).with(Connfu::Commands::Hangup.new(:from => 'client-address', :to => 'server-address'))
      subject.hangup
    end
  end

  describe 'transfer' do
    it 'should send Transfer command to adaptor' do
      transfer_to = 'sip:1652@connfu.com'
      Connfu.adaptor.should_receive(:send_command).with(Connfu::Commands::Transfer.new(:from => 'client-address', :to => 'server-address', :transfer_to => transfer_to))
      subject.transfer(transfer_to)
    end
  end
end