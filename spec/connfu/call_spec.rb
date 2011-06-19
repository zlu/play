require 'spec_helper'

describe Connfu::Call do
  before do
    @to = 'sip:usera@127.0.01'
    @call = Connfu::Call.new(@to)
  end

  it 'should have a state attribute' do
    @call.should respond_to :state
  end
end