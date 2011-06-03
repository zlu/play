require 'spec_helper'

describe Connfu::CallContext do
  it 'should respond to call_id' do
    Connfu::CallContext.new.should respond_to(:call_id)
  end
end