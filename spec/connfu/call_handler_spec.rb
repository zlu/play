require 'spec_helper'

class Connfu::CallHandler
  def answer
    wait
  end

  def say(text)
  end

  def handle(event)
    continue
  end

  def continue
    @continuation.call
  end

  private

  def wait
    callcc do |cc|
      @continuation = cc
      throw :waiting
    end
  end
end

class SimpleCallHandler < Connfu::CallHandler
  def start
    answer
    say "hello"
  end
end

describe Connfu::CallHandler do
  describe "A simple call handler" do
    subject do
      SimpleCallHandler.new
    end

    it "should not call say without acknowledge to answer" do
      subject.expects(:say).never
      handling_messages do
        subject.start
      end
    end

    it "should call say once acknowledgement to answer is handled" do
      subject.expects(:say).with("hello")

      handling_messages :answer_acknowledge do
        subject.start
      end
    end

    def handling_messages(*messages, &block)
      catch :waiting do
        yield
      end
      if m = messages.shift
        subject.handle m
      end
    end
  end
end

# class CallHandler
#   def start
#     answer
#     say "hello"
#     hangup
#   end
# end
#
# handler = CallHandler.new
# handler.start
#
# handler should call "answer"
# handler should not call "say"
#
#
#
# handler.handle(answer_acknowledge)
# handler should perform "say"
# handler should not perform "hangup"
#
#
#
# handler.handle(answer_acknowledge)
# handler.handle(say_acknowledge)
# handler should not perform "hangup"
#
#
#
# handler.handle(answer_acknowledge)
# handler.handle(say_acknowledge)
# handler.handle(say_complete)
# handler should perform "hangup"
