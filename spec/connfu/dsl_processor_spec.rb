require 'spec_helper'

answer_test = <<"FIRST"
class FirstDslTest
  include Connfu

  on :offer do
    answer
  end
end
FIRST

say_test = <<SECOND
class SecondDslTest
  include Connfu

  on :offer do
    answer
    say 'hi'
    hangup
  end
end
SECOND

full_test = <<FULLTEST
#!/usr/bin/env ruby

$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require 'rubygems'
require File.join(File.expand_path('../../lib', __FILE__), 'connfu')

Connfu.setup "usera@localhost", "1"

class AnswerExample
  include Connfu

  on :offer do
    answer
    say('hello.  this is connfu')
  end
end

AnswerExample.new
Connfu.start
FULLTEST

empty_test = <<EMPTYTEST
class FirstDslTest
  include Connfu

  on :offer do
  end
end
EMPTYTEST

redirect_test = <<REDIRECTTEST
class RedirectTest
  include Connfu

  on :offer do
    redirect('sip:16508983130@127.0.0.1')
  end
end
REDIRECTTEST

ask_test = <<ASKTEST
class AskExample
  include Connfu

  on :offer do
    answer
    ask('please enter a four digit pin') do |result|
      say 'your input is ' + result
    end
  end
end
ASKTEST

describe Connfu::DslProcessor do
  before do
    @dp = Connfu::DslProcessor.new
  end

  it "should parse empty test correctly" do
    exp = ParseTree.new.process(empty_test)
    @dp.process(exp)
    @dp.handlers.should eq []
  end

  it "should parse answer test correctly" do
    exp = ParseTree.new.process(answer_test)
    @dp.process(exp)
    @dp.handlers.should eq [:answer]
  end

  it "should parse say test correctly" do
    exp = ParseTree.new.process(say_test)
    @dp.process(exp)
    @dp.handlers.should eq [:answer, {:say => "hi"}, :hangup]
  end

  it "should parse full test correctly" do
    exp = ParseTree.new.process(full_test)
    @dp.process(exp)
    @dp.handlers.should eq [:answer, {:say => "hello.  this is connfu"}]
  end

  it 'should parse redirect test correctly' do
    exp = ParseTree.new.process(redirect_test)
    @dp.process(exp)
    @dp.handlers.should eq [{:redirect => "sip:16508983130@127.0.0.1"}]
  end

  context 'for ask test' do
    before do
      exp = ParseTree.new.process(ask_test)
      @dp.process(exp)
    end

    it 'should parse ask test correctly' do
      @dp.handlers.should eq [:answer, {:ask=>"please enter a four digit pin"}]
    end

    it 'should populate ash_handler' do
      block = {'result' => "say((\"your input is \" + result))"}
      @dp.ask_handler.should eq block
    end
  end
end