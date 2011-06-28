require 'spec_helper'
describe Connfu::Continuation do
  describe "A dsl using continuation" do
    class MyTrivialDSLExample
      include Connfu::Continuation

      def method_which_waits
        wait
      end

      def next_method
      end

      def start
        method_which_waits
        next_method
      end
    end

    subject do
      MyTrivialDSLExample.new
    end

    it "should not call next method without acknowledge to previous synchronous method" do
      subject.should_not_receive(:next_method)
      handling_messages do
        subject.start
      end
    end

    it "should call next method once acknowledgement to synchronous method is handled" do
      subject.should_receive(:next_method)

      handling_messages :acknowledgement do
        subject.start
      end
    end

    it "should only call next_method once, even when continue called twice" do
      subject.should_receive(:next_method).once

      handling_messages :acknowledgement do
        subject.start
      end

      subject.continue
    end

    def handling_messages(*messages, &block)
      catch :waiting do
        yield
      end
      if messages.shift == :acknowledgement
        subject.continue
      end
    end
  end
end