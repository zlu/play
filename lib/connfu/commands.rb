require 'connfu'

module Connfu
  class Commands

    def self.answer
      iq = Blather::Stanza::Iq.new(:set)
      Nokogiri::XML::Builder.with(iq) do |xml|
        xml.answer("xmlns" => "urn:xmpp:ozone:answer:1")
      end
      ap iq
      iq
    end

  end
end