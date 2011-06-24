require "spec_helper"

describe Connfu::Ozone do

  describe "generating XMPP iq" do

    describe "for the Answer command" do
      subject do
        Connfu::Ozone.iq_from_command(Connfu::Commands::Answer.new(:to => 'server-address', :from => 'client-address'))
      end

      it "should generate answer iq from Answer command" do
        subject.xpath("//x:answer", "x" => "urn:xmpp:ozone:1").should_not be_empty
      end

      it "should send the command 'to' the server" do
        subject.xpath("/iq").first.attributes["to"].value.should eq "server-address"
      end

      it "should send the command 'from' the client" do
        subject.xpath("/iq").first.attributes["from"].value.should eq "client-address"
      end
    end

    describe "for the Say command" do
      subject do
        command = Connfu::Commands::Say.new(:to => 'server-address', :from => 'client-address', :text => "Hello")
        Connfu::Ozone.iq_from_command(command)
      end
    
      it "should generate say iq" do
        subject.xpath("//x:say", "x" => "urn:xmpp:ozone:say:1").should_not be_empty
      end

      it "should send the command 'to' the server" do
        subject.xpath("/iq").first.attributes["to"].value.should eq "server-address"
      end

      it "should include the text to be spoken" do
        subject.xpath("//x:say", "x" => "urn:xmpp:ozone:say:1").first.inner_text.should eq "Hello"
      end
    end
  end

end