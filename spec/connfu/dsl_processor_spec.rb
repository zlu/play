require 'spec_helper'

first_test = <<"FIRST"
class FirstDslTest
  include Connfu

  on :offer do
    answer
  end
end
FIRST

second_test = <<SECOND
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

describe Connfu::DslProcessor do
  before do
    @dp = Connfu::DslProcessor.new
  end

  it "should parse first test correctly" do
    exp = ParseTree.new.parse_tree_for_string(first_test)
    @dp.process(exp[0])
    Connfu::DslProcessor.handlers.should eq [:answer]
  end

  it "should parse second test correctly" do
    exp = ParseTree.new.parse_tree_for_string(second_test)
    @dp.process(exp[0])
    Connfu::DslProcessor.handlers.should eq [:answer, {:say=>"hi"}, :hangup]
  end

  it "should parse full test correctly" do
    exp = ParseTree.new.parse_tree_for_string(full_test)
    @dp.process(exp[0])
    Connfu::DslProcessor.handlers.should eq [:answer, {:say=>"hello.  this is connfu"}]
  end
end