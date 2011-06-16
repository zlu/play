module Connfu
  class Error < Blather::Stanza::Iq
    def self.create_from_presence(offer)
      xml = offer
      doc = Nokogiri::XML.parse xml
      self.import(doc.root)
    end
  end
end