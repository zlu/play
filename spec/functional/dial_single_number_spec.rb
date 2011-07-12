require 'spec_helper'

describe "Dialing a single number" do
  testing_dsl do
    dial :to => "someone-remote", :from => "my-number"

    on :answer do
      say 'something'
    end
  end

  before :each do
    @call_id = 'outbound_call_id'
    @dsl_class.on_ready
  end

  it "should send a dial command when Connfu starts" do
    Connfu.adaptor.commands.last.should == Connfu::Commands::Dial.new(:to => 'someone-remote', :from => "my-number")
  end

  it 'should send a say command when the call is answered' do
    incoming :outgoing_call_ringing_presence, @call_id
    incoming :outgoing_call_answered_presence, @call_id

    Connfu.adaptor.commands.last.should == Connfu::Commands::Say.new(:text => 'something', :to => "#{@call_id}@#{PRISM_HOST}", :from => "#{PRISM_JID}/voxeo")
  end
end