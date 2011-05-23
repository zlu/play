module Connfu
  module IqParser
    def parse(iq)
      l.debug iq
      doc = Nokogiri::XML.parse iq
      node = Blather::XMPPNode.import(doc.root)
      if node && node.children && node.children[1] && node.children[1].name.eql?('offer')
        Connfu::Offer.import(node)
      else
        Connfu::Error.import(node)
      end
    end
  end
end