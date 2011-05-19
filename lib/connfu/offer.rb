module Connfu
  class Offer < Blather::Stanza::Iq
    def self.new
      super(:set)
    end

    def self.create_from_iq(offer_iq)
      xml = offer_iq
      doc = Nokogiri::XML.parse xml
      Blather::XMPPNode.import(doc.root)
    end
  end
end