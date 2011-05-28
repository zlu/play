module Connfu
  module IqParser
    def self.parse(iq)
      doc = Nokogiri::XML.parse(iq.to_xml)
      node = Blather::XMPPNode.import(doc.root)
      result_node = nil
      l.debug iq.type
      if iq.to_xml.match(/.*<offer.*/)
        result_node = Connfu::Offer.import(node)
      elsif iq.to_xml.match(/.*<complete.*urn:xmpp:ozone:say:1.*/)
        result_node = Connfu::Event::SayComplete.import(node)
      elsif iq.type == :result
        result_node = Connfu::Result.import(node)
      else
        result_node = Connfu::Error.import(node)
      end

      result_node
    end

    def self.fire_event(clazz)
      l.debug Connfu.dsl_processor.handlers
      command = Connfu.dsl_processor.handlers.shift
      if command.instance_of?(Hash)
        l.debug "fire_event: #{clazz} #{command.keys.first} with #{command.values.first}"
        clazz.send command.keys.first, command.values.first
      else
        l.debug "fire_event: #{clazz} #{command}"
        clazz.module_eval "#{command}"
      end
    end
  end
end