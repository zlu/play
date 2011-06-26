module Connfu
  module IqParser
    # def self.parse(node)
    #   xml_iq = node.to_xml
    #   result_node = nil
    #   if xml_iq.match(/.*<offer.*/)
    #   elsif !node.xpath('//x:success', 'x' => 'urn:xmpp:ozone:say:complete:1').empty?
    #     result_node = Connfu::Event::SayComplete.import(node)
    #   elsif !node.xpath('//x:success', 'x' => 'urn:xmpp:ozone:ask:complete:1').empty?
    #     result_node = Connfu::Event::AskComplete.import(node)
    #     result_node.react
    #   elsif node.type == :result
    #     result_node = node.xpath('//oc:ref', 'oc' => 'urn:xmpp:ozone:1').empty? ? \
    #                   # Connfu::Event::Result.import(node) : \
    #                   @handler.handle(:something) : \
    #                   Connfu::Event::OutboundResult.import(node)
    #   elsif !node.xpath('//x:answered', 'x' => 'urn:xmpp:ozone:1').empty?
    #     result_node = Connfu::Event::Answered.import(node)
    #   elsif !node.xpath('//x:end', 'x' => 'urn:xmpp:ozone:1').empty?
    #     result_node = Connfu::Event::End.import(node)
    #   else
    #
    #   end
    #
    #   result_node
    # end

    def self.parse(node)
      handle_event_catching_waiting(parse_event_from(node))
    end

    def self.parse_event_from(node)
      if !node.xpath('//x:offer', 'x' => 'urn:xmpp:ozone:1').empty?
        presence_node = node.xpath('/presence').first
        p_attrs = presence_node.attributes
        Connfu::Event::Offer.new(:from => p_attrs['from'].value, :to => p_attrs['to'].value)
      elsif !node.xpath('//x:success', 'x' => 'urn:xmpp:ozone:say:complete:1').empty?
        Connfu::Event::SayComplete.new
      elsif node.type == :result
        Connfu::Event::Result.new
      end
    end

    def self.handle_event_catching_waiting(event)
      catch :waiting do
        handle_event(event)
      end
    end

    def self.handle_event(event)
      case event
      when Connfu::Event::Offer
        @handler = Connfu.handler_class.new(:from => event.presence_from, :to => event.presence_to)
        @handler.run
      when Connfu::Event::Result
        l.debug '+++++++++++++++handle'
        @handler.handle
      end
    end
  end
end