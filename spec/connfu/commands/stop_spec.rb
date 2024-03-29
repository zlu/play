require "spec_helper"

describe Connfu::Commands::Stop do
  
  describe "generating XMPP iq for a Stop command" do
    subject do
      Connfu::Commands::Stop.new(:call_jid => 'call-jid', :client_jid => 'client-jid', :component_id => 'abc123').to_iq
    end

    it "should generate a stop iq" do
      subject.xpath("//x:stop", "x" => rayo('ext:1')).should_not be_empty
    end

    it "should be an iq of type 'set'" do
      subject.type.should eq :set
    end

    it "should contain the 'to' address with the component_id in the iq" do
      subject.xpath("/iq").first.attributes["to"].value.should eq "call-jid/abc123"
    end

    it "should contain the 'from' address in the iq" do
      subject.xpath("/iq").first.attributes["from"].value.should eq "client-jid"
    end

    it 'should not set any other iq attributes' do
      node = subject.xpath("//x:stop", "x" => rayo('ext:1')).first
      node.attributes.size.should eq 0
    end
  end
  
end