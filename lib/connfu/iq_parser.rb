module Connfu
  module IqParser
    def self.parse(node)
      xml_iq = node.to_xml
      result_node = nil
      if xml_iq.match(/.*<offer.*/)
        result_node = Connfu::Offer.import(node)
#        Connfu::Event::Result.create(result_node)
      elsif xml_iq.match(/.*<complete.*urn:xmpp:ozone:say:1.*/)
        result_node = Connfu::Event::SayComplete.import(node)
      elsif xml_iq.match(/.*<complete.*urn:xmpp:ozone:ask:1.*/)
        result_node = Connfu::Event::AskComplete.import(node)
        result_node.react
      elsif node.type == :result
        result_node = node.xpath('//oc:ref', 'oc' => 'urn:xmpp:ozone:1').empty? ? \
                      Connfu::Event::Result.import(node) : \
                      Connfu::Event::OutboundResult.import(node)
      elsif !node.xpath('//x:answered', 'x' => 'urn:xmpp:ozone:1').first.nil?
        answered = node.xpath('//x:answered', 'x' => 'urn:xmpp:ozone:1').first
        result_node = Connfu::Event::Answered.import(answered)
      else
        result_node = Connfu::Error.import(node)
      end

      self.fire_event
      result_node
    end

    def self.fire_event
      clazz = Connfu.base
      l.debug Connfu.dsl_processor.handlers
      command = Connfu.dsl_processor.handlers.shift
      l.debug command
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