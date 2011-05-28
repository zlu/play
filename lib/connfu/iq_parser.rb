module Connfu
  module IqParser
    def parse(iq)
      doc = Nokogiri::XML.parse iq
      node = Blather::XMPPNode.import(doc.root)
      if iq.match(/.*<offer.*/)
        Connfu::Offer.import(node)
      elsif iq.match(/.*<complete.*urn:xmpp:ozone:say:1.*/)
        Connfu::Event::SayComplete.import(node)
      else
        Connfu::Error.import(node)
      end
    end
  end
end