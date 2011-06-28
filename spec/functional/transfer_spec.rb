require "spec_helper"

describe "a call transfer" do
  class TransferExample
    include Connfu::Dsl

    on :offer do
      answer
      if transfer('sip:userb@127.0.0.1')
        say('transfer was successful')
      else
        say('sorry nobody is available at the moment')
      end
    end
  end

  before do
    @server_address = "34209dfiasdoaf@server.whatever"
    @client_address = "usera@127.0.0.whatever"
    Connfu.setup "@client_address", "1"
    Connfu.handler_class = TransferExample

    Connfu.adaptor = TestConnection.new
  end

  it "should send a transfer command" do
    run_fake_event_loop Connfu::Event::Offer.new(:from => @server_address, :to => @client_address)

    Connfu.adaptor.commands.last.should == Connfu::Commands::Transfer.new(:transfer_to => ['sip:userb@127.0.0.1'], :to => @server_address, :from => @client_address)
  end

  it "should indicate that the call has been transferred successfully" do
    run_fake_event_loop Connfu::Event::Offer.new(:from => @server_address, :to => @client_address),
                        Connfu::Event::TransferSuccess.new

    Connfu.adaptor.commands.last.should == Connfu::Commands::Say.new(:text => 'transfer was successful', :to => @server_address, :from => @client_address)
  end

  it "should indicate that the call transfer has been timed out" do
    run_fake_event_loop Connfu::Event::Offer.new(:from => @server_address, :to => @client_address),
                        Connfu::Event::TransferTimeout.new

    Connfu.adaptor.commands.last.should == Connfu::Commands::Say.new(:text => 'sorry nobody is available at the moment', :to => @server_address, :from => @client_address)
  end
end

describe "a round-robin call transfer" do
  class RoundRobinTransferExample
    include Connfu::Dsl

    on :offer do
      answer
      if transfer('sip:userb@127.0.0.1', 'sip:userc@127.0.0.1', :mode => :round_robin)
        say('transfer was successful')
      else
        say('sorry nobody is available at the moment')
      end
    end
  end

  before do
    @server_address = "34209dfiasdoaf@server.whatever"
    @client_address = "usera@127.0.0.whatever"
    Connfu.setup "@client_address", "1"
    Connfu.handler_class = RoundRobinTransferExample

    Connfu.adaptor = TestConnection.new
  end

  it "should send a transfer command for the first sip address" do
    run_fake_event_loop Connfu::Event::Offer.new(:from => @server_address, :to => @client_address)

    Connfu.adaptor.commands.last.should == Connfu::Commands::Transfer.new(:transfer_to => ['sip:userb@127.0.0.1'], :to => @server_address, :from => @client_address)
  end

  it "should continue to execute the next command if transfer to first sip address is successful" do
    run_fake_event_loop Connfu::Event::Offer.new(:from => @server_address, :to => @client_address),
                        Connfu::Event::TransferSuccess.new

    Connfu.adaptor.commands.last.should == Connfu::Commands::Say.new(:text => 'transfer was successful', :to => @server_address, :from => @client_address)
  end

  it "should send a transfer command for the second sip address if the first one times out" do
    run_fake_event_loop Connfu::Event::Offer.new(:from => @server_address, :to => @client_address),
                        Connfu::Event::TransferTimeout.new

    Connfu.adaptor.commands.last.should == Connfu::Commands::Transfer.new(:transfer_to => ['sip:userc@127.0.0.1'], :to => @server_address, :from => @client_address)
  end

  it "should indicate second transfer was successful" do
    run_fake_event_loop Connfu::Event::Offer.new(:from => @server_address, :to => @client_address),
                        Connfu::Event::TransferTimeout.new,
                        Connfu::Event::TransferSuccess.new

    Connfu.adaptor.commands.last.should == Connfu::Commands::Say.new(:text => 'transfer was successful', :to => @server_address, :from => @client_address)
  end

  it "should indicate both transfers time out" do
    run_fake_event_loop Connfu::Event::Offer.new(:from => @server_address, :to => @client_address),
                        Connfu::Event::TransferTimeout.new,
                        Connfu::Event::TransferTimeout.new

    Connfu.adaptor.commands.last.should == Connfu::Commands::Say.new(:text => 'sorry nobody is available at the moment', :to => @server_address, :from => @client_address)
  end

end