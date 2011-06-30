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
    Connfu.adaptor = TestConnection.new
    Connfu.event_processor = Connfu::EventProcessor.new(ErrorExample)
  end

  it "should raise an exception if the server responds with an error" do
    ErrorExample.any_instance.should_receive(:error_caught!)

    Connfu.handle_stanza(create_stanza(offer_presence))
    Connfu.handle_stanza(create_iq(error_iq))
  end

  it "should continue to execute once the result of the answer is received" do
    ErrorExample.any_instance.should_receive(:do_something)

    Connfu.handle_stanza(create_stanza(offer_presence))
    Connfu.handle_stanza(create_iq(result_iq))
  end
end