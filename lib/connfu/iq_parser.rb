module Connfu
  module IqParser
    def self.parse(iq)
      doc = Nokogiri::XML.parse(iq.to_xml)
      node = Blather::XMPPNode.import(doc.root)
      if iq.to_xml.match(/.*<offer.*/)
        Connfu::Offer.import(node)
      elsif iq.to_xml.match(/.*<complete.*urn:xmpp:ozone:say:1.*/)
        Connfu::Event::SayComplete.import(node)
      else
        Connfu::Error.import(node)
      end
    end

    def self.fire_event(clazz)
      command = Connfu::DslProcessor.handlers.shift
      clazz.module_eval command
    end
  end
end