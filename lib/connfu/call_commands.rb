module Connfu
  module CallCommands
#    def answer_iq(to)
#      iq = Blather::Stanza::Iq.new(:set, to)
#      Nokogiri::XML::Builder.with(iq) do |xml|
#        xml.answer("xmlns" => "urn:xmpp:ozone:1")
#      end
#      iq
#    end

    def answer
      l.info 'answer'
      Connfu.connection.write answer_iq(Connfu.context.from.to_s)
    end

    ['accept', 'answer', 'hangup', 'reject'].each do |call_command|
      define_method :"#{call_command}_iq" do |to|
        iq = Blather::Stanza::Iq.new(:set, to)
        Nokogiri::XML::Builder.with(iq) do |xml|
          xml.send call_command, {"xmlns" => "urn:xmpp:ozone:1"}
        end
        l.info "define_method"
        ap iq
        iq
      end
    end
  end
end