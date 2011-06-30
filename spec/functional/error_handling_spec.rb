require "spec_helper"

describe "a call transfer" do
  class ErrorExample
    include Connfu::Dsl

    on :offer do
      begin 
        answer
      rescue Object => e
        error_caught!
      end
    end
  end

  before do
    Connfu.adaptor = TestConnection.new
  end
  
  subject do
    ErrorExample.new :from => 'a', :to => 'b'
  end
  
  it "should raise an exception if the server responds with an error" do
    subject.start
    subject.should_receive(:error_caught!)
    subject.handle_event Connfu::Event::Error.new
  end
end