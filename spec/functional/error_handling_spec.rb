require "spec_helper"

describe "receiving an error from the server" do
  class ErrorExample
    include Connfu::Dsl

    on :offer do
      begin
        answer
        do_something
      rescue Object => e
        error_caught!
      end
    end
  end

  before do
    setup_connfu ErrorExample
  end

  it "should raise an exception if the server responds with an error" do
    ErrorExample.any_instance.should_receive(:error_caught!)

    incoming :offer_presence
    incoming :error_iq
  end
end