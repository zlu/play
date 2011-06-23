module Connfu
  module IqParser
    def self.parse(node)
      p node
      xml_iq = node.to_xml
      
      if xml_iq.match(/.*<offer.*/)
        Connfu::Offer.import(node)
        @handler = AnswerExample.new.on_offer
      
      #         result_node = Connfu::Offer.import(node)
      #       elsif !node.xpath('//x:success', 'x' => 'urn:xmpp:ozone:say:complete:1').empty?
      #         result_node = Connfu::Event::SayComplete.import(node)
      #       elsif !node.xpath('//x:success', 'x' => 'urn:xmpp:ozone:ask:complete:1').empty?
      #         result_node = Connfu::Event::AskComplete.import(node)
      #         result_node.react
      #       elsif node.type == :result
      #         result_node = node.xpath('//oc:ref', 'oc' => 'urn:xmpp:ozone:1').empty? ? \
      #                       Connfu::Event::Result.import(node) : \
      #                       Connfu::Event::OutboundResult.import(node)
      elsif !node.xpath('//x:answered', 'x' => 'urn:xmpp:ozone:1').empty?
        result_node = Connfu::Event::Answered.import(node)
      end
      #       elsif !node.xpath('//x:end', 'x' => 'urn:xmpp:ozone:1').empty?
      #         result_node = Connfu::Event::End.import(node)
      #       else
      # 
      #       end
      # 
      #       self.fire_event
      #       result_node
    end

    def self.fire_event
      clazz = Connfu.base
      l.debug Connfu.dsl_processor.handlers
      if (command = Connfu.dsl_processor.handlers.shift)
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
end