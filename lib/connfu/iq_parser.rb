module Connfu
  module IqParser
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
        Connfu.handler = Connfu.handler_class.new(:from => event.presence_from, :to => event.presence_to)
        Connfu.handler.run
      when Connfu::Event::SayComplete
        Connfu.handler.continue
      end
    end
  end
end