module Connfu
  module CallCommands
    def answer_iq(to)
      iq = Blather::Stanza::Iq.new(:set, to)
      Nokogiri::XML::Builder.with(iq) do |xml|
        xml.answer("xmlns" => "urn:xmpp:ozone:1")
      end
      iq
    end

    def answer
      l.info 'answer'
      Connfu.connection.write answer_iq(Connfu.context.from.to_s)
    end
  end
end