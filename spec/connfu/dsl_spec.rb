require_relative '../spec_helper'

describe Connfu::Dsl do
  class DslTest
    include Connfu::Dsl
  end

  before do
    Connfu.adaptor = TestConnection.new
    subject.stub(:wait)
  end

  subject {
    DslTest.new(:from => "server-address", :to => "client-address")
  }

  describe 'say' do
    it 'should send Say command to adaptor' do
      text = 'connfu is awesome'
      Connfu.adaptor.should_receive(:send_command).with(Connfu::Commands::Say.new(:text => text, :from => 'client-address', :to => 'server-address'))
      catch :waiting do
        subject.say(text)
      end
    end
  end

  describe 'hangup' do
    it 'should send Hangup command to adaptor' do
      Connfu.adaptor.should_receive(:send_command).with(Connfu::Commands::Hangup.new(:from => 'client-address', :to => 'server-address'))
      subject.hangup
    end
  end

  describe 'reject' do
    it 'should send Reject command to adaptor' do
      Connfu.adaptor.should_receive(:send_command).with(Connfu::Commands::Reject.new(:from => 'client-address', :to => 'server-address'))
      subject.reject
    end
  end

  describe 'redirect' do
    it 'should send Redirect command to adaptor' do
      redirect_to = 'sip:1652@connfu.com'
      Connfu.adaptor.should_receive(:send_command).with(Connfu::Commands::Redirect.new(:redirect_to => redirect_to, :from => 'client-address', :to => 'server-address'))
      subject.redirect(redirect_to)
    end
  end

  describe 'transfer' do
    it 'should send Transfer command to adaptor' do
      transfer_to = 'sip:1652@connfu.com'
      Connfu.adaptor.should_receive(:send_command).with(Connfu::Commands::Transfer.new(:transfer_to => [transfer_to], :from => 'client-address', :to => 'server-address'))
      catch :waiting do
        subject.transfer(transfer_to)
      end
    end
    
    it 'should send Transfer command with optional timeout' do
      transfer_to = 'sip:1652@connfu.com'
      timeout_in_seconds = 5
      cmd = Connfu::Commands::Transfer.new(:transfer_to => [transfer_to], :from => 'client-address', :to => 'server-address', :timeout => (timeout_in_seconds * 1000))
      Connfu.adaptor.should_receive(:send_command).with(cmd)
      catch :waiting do
        subject.transfer(transfer_to, :timeout => timeout_in_seconds)
      end      
    end
  end

  describe '#handle_event(event)' do
    it "a result event" do
      subject.should_receive(:continue)
      subject.handle_event(Connfu::Event::Result.new)
    end

    it "a say complete" do
      subject.should_receive(:continue)
      subject.handle_event(Connfu::Event::SayComplete.new)
    end
  end
end