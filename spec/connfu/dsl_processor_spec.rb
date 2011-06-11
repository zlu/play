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
    ask('please enter your four digit pin') do |result|
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
    exp = ParseTree.new.parse_tree_for_string(empty_test)
    @dp.process(exp[0])
    @dp.handlers.should eq []
  end

  it "should parse answer test correctly" do
    exp = ParseTree.new.parse_tree_for_string(answer_test)
    @dp.process(exp[0])
    @dp.handlers.should eq [:answer]
  end

  it "should parse say test correctly" do
    exp = ParseTree.new.parse_tree_for_string(say_test)
    @dp.process(exp[0])
    @dp.handlers.should eq [:answer, {:say => "hi"}, :hangup]
  end

  it "should parse full test correctly" do
    exp = ParseTree.new.parse_tree_for_string(full_test)
    @dp.process(exp[0])
    @dp.handlers.should eq [:answer, {:say => "hello.  this is connfu"}]
  end

  it 'should parse redirect test correctly' do
    exp = ParseTree.new.parse_tree_for_string(redirect_test)
    @dp.process(exp[0])
    @dp.handlers.should eq [{:redirect => "sip:16508983130@127.0.0.1"}]
  end

  it 'should parse ask test correctly' do
    exp = ParseTree.new.parse_tree_for_string(ask_test)
    l.debug exp[0]
    @dp.process(exp[0])
    l.debug @dp.handlers
    @dp.handlers.should eq [{:ask => "please input a four digit pin"}]
  end
end