require 'spec_helper'

describe "Dialing a single number" do
  testing_dsl do
    def do_something
    end

    dial :to => "someone-remote", :from => "my-number" do |call|
      call.on_ringing do
        do_something
      end
      call.on_answer do
        say 'something'
        say 'another thing'
      end
    end
  end

  before :each do
    @call_id = 'outbound_call_id'
    @dsl_class.on_ready
  end

  it "should send a dial command when Connfu starts" do
    Connfu.adaptor.commands.last.should == Connfu::Commands::Dial.new(:to => 'someone-remote', :from => "my-number")
  end

  it 'should call the do_something method when the call starts ringing' do
    dsl_instance.should_receive :do_something

    incoming :outgoing_call_ringing_presence, @call_id
  end

  it 'should send a say command when the call is answered' do
    incoming :outgoing_call_ringing_presence, @call_id
    incoming :outgoing_call_answered_presence, @call_id

    Connfu.adaptor.commands.last.should == Connfu::Commands::Say.new(:text => 'something', :to => "#{@call_id}@#{PRISM_HOST}", :from => "#{PRISM_JID}/voxeo")
  end

  it 'should only invoke the second say once the first has completed' do
    incoming :outgoing_call_ringing_presence, @call_id
    incoming :outgoing_call_answered_presence, @call_id
    incoming :result_iq, @call_id
    incoming :say_complete_success, @call_id

    Connfu.adaptor.commands.last.should == Connfu::Commands::Say.new(:text => 'another thing', :to => "#{@call_id}@#{PRISM_HOST}", :from => "#{PRISM_JID}/voxeo")
  end

end