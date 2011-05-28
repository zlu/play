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

describe Connfu::DslProcessor do
  before do
    @dp = Connfu::DslProcessor.new
  end

  it "should parse first test correctly" do
    exp = ParseTree.new.parse_tree_for_string(first_test)
    l.debug exp
    @dp.process(exp[0])
    @dp.handlers.should eq [:answer]
  end

  it "should parse second test correctly" do
    exp = ParseTree.new.parse_tree_for_string(second_test)
    l.debug exp
    @dp.process(exp[0])
    @dp.handlers.should eq [:answer, {:say=>"hi"}, :hangup]
  end
end