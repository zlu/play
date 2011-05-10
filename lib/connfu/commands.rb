require 'connfu'

module Connfu
  class Commands

    def self.answer(to)
      iq = Blather::Stanza::Iq.new(:set, to)
      Nokogiri::XML::Builder.with(iq) do |xml|
        xml.answer("xmlns" => "urn:xmpp:ozone:1")
      end
ap iq
      iq
    end

  end
end