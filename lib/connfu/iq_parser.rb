module Connfu
  module IqParser
    def parse(iq)
      l.debug iq
      doc = Nokogiri::XML.parse iq
      node = Blather::XMPPNode.import(doc.root)
      if iq.match(/.*<offer.*/)
        Connfu::Offer.import(node)
      else
        Connfu::Error.import(node)
      end
    end
  end
end