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

    describe 'for the Redirect command' do
      subject do
        @redirect_to = 'sip:1324@connfu.com'
        Connfu::Ozone.iq_from_command(Connfu::Commands::Redirect.new(:redirect_to => @redirect_to, :to => 'server-address', :from => 'client-address'))
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

      it "should generate redirect iq" do
        subject.xpath("//x:redirect", "x" => "urn:xmpp:ozone:1").should_not be_empty
      end

      it "should contain a 'redirect_to' attribute" do
        redirect_node = subject.xpath("//x:redirect", "x" => "urn:xmpp:ozone:1").first
        redirect_node.attributes['to'].value.should eq @redirect_to
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

    describe 'for the Transfer command' do
      subject do
        @transfer_to = 'sip:1324@connfu.com'
        Connfu::Ozone.iq_from_command(Connfu::Commands::Transfer.new(:to => 'server-address', :from => 'client-address', :transfer_to => @transfer_to))
      end

      it "should generate transfer iq" do
        subject.xpath("//x:transfer", "x" => "urn:xmpp:ozone:transfer:1").should_not be_empty
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
      
      it 'should not contain a timeout attribute' do
        transfer_node = subject.xpath("x:transfer", "x" => "urn:xmpp:ozone:transfer:1").first
        transfer_node.attributes['timeout'].should be_nil
      end

      context 'with a timeout parameter' do
        subject do
          @transfer_to = 'sip:1324@connfu.com'
          Connfu::Ozone.iq_from_command(Connfu::Commands::Transfer.new(:to => 'server-address', :from => 'client-address', :transfer_to => @transfer_to, :timeout => 5000))
        end

        it 'should contain a timeout attribute when it is passed in as an option' do
          transfer_node = subject.xpath("x:transfer", "x" => "urn:xmpp:ozone:transfer:1").first
          transfer_node.attributes['timeout'].value.should eq "5000"
        end

      end
      
      context 'when transfer to a single end-point' do
        it "should contain a 'transfer_to' node" do
          transfer_to_node = subject.xpath("//x:to", "x" => "urn:xmpp:ozone:transfer:1").first
          transfer_to_node.name.should eq 'to'
          transfer_to_node.text.should eq @transfer_to
        end
      end

      context 'when transfer to multiple end-points' do
        subject do
          @transfer_to = ['sip:1324@connfu.com', 'sip:3432@connfu.com']
          Connfu::Ozone.iq_from_command(Connfu::Commands::Transfer.new(:to => 'server-address', :from => 'client-address', :transfer_to => @transfer_to))
        end

        it "should contain correct number of 'transfer_to' nodes" do
          transfer_to_nodes = subject.xpath("//x:to", "x" => "urn:xmpp:ozone:transfer:1")
          transfer_to_nodes.size.should eq @transfer_to.length
          transfer_to_nodes.each_with_index do |n, i|
            n.name.should eq 'to'
            n.text.should eq @transfer_to[i]
          end
        end
      end
    end
  end
end