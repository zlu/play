require 'spec_helper'

describe Connfu::Dsl do
  class DslTest
    include Connfu::Dsl
  end

  subject {
    DslTest.new(:from => "server-address", :to => "client-address")
  }

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
end