module Connfu
  class Error < Blather::Stanza::Iq
    def self.create_from_iq(offer_iq)
      xml = offer_iq
      doc = Nokogiri::XML.parse xml
      self.import(doc.root)
    end
  end
end