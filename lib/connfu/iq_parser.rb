module Connfu
  module IqParser
    def self.parse(iq)
      xml_iq = iq.to_xml
      doc = Nokogiri::XML.parse(xml_iq)
      node = Blather::XMPPNode.import(doc.root)
      result_node = nil
      if xml_iq.match(/.*<offer.*/)
        result_node = Connfu::Offer.import(node)
        Connfu::Event::Result.create(result_node)
      elsif xml_iq.match(/.*<complete.*urn:xmpp:ozone:say:1.*/)
        result_node = Connfu::Event::SayComplete.import(node)
      elsif xml_iq.match(/.*<complete.*urn:xmpp:ozone:ask:1.*/)
        result_node = Connfu::Event::AskComplete.import(node)
        result_node.react
      elsif iq.type == :result
        result_node = iq.xpath('/iq/ref').empty? ? \
                      Connfu::Event::Result.import(node) : \
                      Connfu::Event::OutboundResult.import(node)
      else
        result_node = Connfu::Error.import(node)
      end

      self.fire_event
      result_node
    end

    def self.fire_event
      clazz = Connfu.base
#      l.debug Connfu.dsl_processor.handlers
      command = Connfu.dsl_processor.handlers.shift
#      l.debug command
      if command.instance_of?(Hash)
#        l.debug "fire_event: #{clazz} #{command.keys.first} with #{command.values.first}"
        clazz.send command.keys.first, command.values.first
      else
#        l.debug "fire_event: #{clazz} #{command}"
        clazz.module_eval "#{command}"
      end
    end
  end
end