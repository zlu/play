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

      it "should be an iq of type 'set'" do
        subject.type.should eq :set
      end

      it "should send the command 'to' the server" do
        subject.xpath("/iq").first.attributes["to"].value.should eq "server-address"
      end

      it "should send the command 'from' the client" do
        subject.xpath("/iq").first.attributes["from"].value.should eq "client-address"
      end
    end

    describe "for the Accept command" do
      subject do
        Connfu::Ozone.iq_from_command(Connfu::Commands::Accept.new(:to => 'server-address', :from => 'client-address'))
      end

      it "should generate accept iq from Accept command" do
        subject.xpath("//x:accept", "x" => "urn:xmpp:ozone:1").should_not be_empty
      end

      it "should be an iq of type 'set'" do
        subject.type.should eq :set
      end

      it "should send the command 'to' the server" do
        subject.xpath("/iq").first.attributes["to"].value.should eq "server-address"
      end

      it "should send the command 'from' the client" do
        subject.xpath("/iq").first.attributes["from"].value.should eq "client-address"
      end
    end

    describe "for the Reject command" do
      subject do
        Connfu::Ozone.iq_from_command(Connfu::Commands::Reject.new(:to => 'server-address', :from => 'client-address'))
      end

      it "should generate reject iq from Reject command" do
        subject.xpath("//x:reject", "x" => "urn:xmpp:ozone:1").should_not be_empty
      end

      it "should be an iq of type 'set'" do
        subject.type.should eq :set
      end

      it "should send the command 'to' the server" do
        subject.xpath("/iq").first.attributes["to"].value.should eq "server-address"
      end

      it "should send the command 'from' the client" do
        subject.xpath("/iq").first.attributes["from"].value.should eq "client-address"
      end
    end

    describe "for the Say component with plain text" do
      subject do
        command = Connfu::Commands::Say.new(:to => 'server-address', :from => 'client-address', :text => "Hello")
        Connfu::Ozone.iq_from_command(command)
      end

      it "should generate say iq" do
        subject.xpath("//x:say", "x" => "urn:xmpp:ozone:say:1").should_not be_empty
      end

      it "should be an iq of type 'set'" do
        subject.type.should eq :set
      end

      it "should send the attribute 'to' in the iq" do
        subject.xpath("/iq").first.attributes["to"].value.should eq "server-address"
      end

      it "should send the attribute 'from' in the iq" do
        subject.xpath("/iq").first.attributes["from"].value.should eq "client-address"
      end

      it "should include the text to be spoken" do
        subject.xpath("//x:say", "x" => "urn:xmpp:ozone:say:1").first.inner_text.should eq "Hello"
      end
    end

    describe "for the Say component with a url" do
      subject do
        @url = "http://www.phono.com/audio/troporocks.mp3"
        command = Connfu::Commands::Say.new(
          :to => 'server-address',
          :from => 'client-address',
          :text => @url)
        Connfu::Ozone.iq_from_command(command)
      end

      it "should contain the 'audio' node with the correct src" do
        audio_node = subject.xpath('//x:audio', 'x' => 'urn:xmpp:ozone:say:1').first
        audio_node.should_not be_nil
        audio_node.attributes['src'].should_not be_nil
        audio_node.attributes['src'].value.should eq @url
      end
    end

    describe "for the Hangup command" do
      subject do
        Connfu::Ozone.iq_from_command(Connfu::Commands::Hangup.new(:to => 'server-address', :from => 'client-address'))
      end

      it "should generate hangup iq" do
        subject.xpath("//x:hangup", "x" => "urn:xmpp:ozone:1").should_not be_empty
      end

      it "should be an iq of type 'set'" do
        subject.type.should eq :set
      end

      it "should contain the 'to' address in the iq" do
        subject.xpath("/iq").first.attributes["to"].value.should eq "server-address"
      end

      it "should contain the 'from' address in the iq" do
        subject.xpath("/iq").first.attributes["from"].value.should eq "client-address"
      end
    end
  end

end