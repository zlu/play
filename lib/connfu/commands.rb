require 'connfu'

module Connfu
  class Commands

    def self.answer_iq(to)
      p 'inside of answer_iq'
      iq = Blather::Stanza::Iq.new(:set, to)
      Nokogiri::XML::Builder.with(iq) do |xml|
        xml.answer("xmlns" => "urn:xmpp:ozone:1")
      end
      ap iq
      iq
    end

    def self.answer(client, to)
      p 'inside of answer'
      client.write answer_iq(to)
    end

  end
end