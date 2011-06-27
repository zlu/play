require 'spec_helper'
describe Connfu::CallHandler do
  describe "A simple call handler" do

    module TrivialDSL
      def method_which_waits
        wait
      end

      def next_method
      end
    end

    class MyTrivialDSLExample
      include Connfu::CallHandler
      include TrivialDSL
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

    def handling_messages(*messages, &block)
      catch :waiting do
        yield
      end
      if m = messages.shift
        subject.handle
      end
    end
  end
end