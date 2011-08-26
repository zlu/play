require "spec_helper"

describe "handling a call offer" do
  testing_dsl do
    def do_something_with(*args); end

    on :offer do |offer|
      do_something_with(
        :from => offer.from,
        :to => offer.to
      )
    end
  end

  let(:actor) { Actor.new("James Adam <sip:james@127.0.0.1>") }

  it "exposes who the call is from" do
    dsl_instance.should_receive(:do_something_with).with(
      hash_including(:from => "James Adam <sip:james@127.0.0.1>")
    )

    actor.call "<sip:usera@127.0.0.1>"
  end

  it "exposes who the call is being routed to" do
    parsed_hash = {
      :address => "sip:usera@127.0.0.1",
      :scheme => "sip",
      :username => "usera",
      :host => "127.0.0.1"
    }

    dsl_instance.should_receive(:do_something_with).with(
      hash_including(:to => parsed_hash)
    )

    actor.call "<sip:usera@127.0.0.1>"
  end

  it "should deal with a call to a raw sip address" do
    parsed_hash = {
      :address => "sip:usera@127.0.0.1",
      :scheme => "sip",
      :username => "usera",
      :host => "127.0.0.1"
    }

    dsl_instance.should_receive(:do_something_with).with(
      hash_including(:to => parsed_hash)
    )

    actor.call "sip:usera@127.0.0.1"
  end

  it "implicitly hangs up once handling is complete" do
    actor.call 

    last_command.should be_instance_of(Connfu::Commands::Hangup)
  end
end

describe "offer which is hungup by the DSL" do
  testing_dsl do
    on :offer do |call|
      answer
      hangup
    end
  end

  let(:actor) { Actor.new("James Adam <sip:james@127.0.0.1>") }

  it "should not issue another hangup after it has been called in the DSL" do
    actor.call

    Connfu.connection.commands.select { |c| c.is_a?(Connfu::Commands::Hangup) }.length.should == 1
  end
end
