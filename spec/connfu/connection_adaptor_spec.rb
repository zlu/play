require "spec_helper"

describe Connfu::LoggingConnectionProxy do
  it "should write XMPP versions of commands to its underlying connection" do
    connection = stub('connection')
    command = stub('command')
    xmpp = stub('xmpp')
    command.stub(:to_iq).and_return(xmpp)

    adaptor = Connfu::LoggingConnectionProxy.new(connection)
    connection.should_receive(:write).with(xmpp)

    adaptor.send_command(command)
  end
end