require 'spec_helper'

describe "Dialing a single number" do
  testing_dsl do
    dial :to => "someone-remote", :from => "my-number"
  end

  before :each do
    @dsl_class.on_ready
  end

  it "should send a dial command when Connfu starts" do
    Connfu.adaptor.commands.last.should == Connfu::Commands::Dial.new(:to => 'someone-remote', :from => "my-number")
  end
end