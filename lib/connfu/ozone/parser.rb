module Connfu
  module Ozone
    module Parser

      def self.parse_event_from(node)
        call_id = node.from.node
        to = node.from.to_s
        from = node.to.to_s

        if node.xpath('//x:offer', 'x' => 'urn:xmpp:ozone:1').any?
          presence_node = node.xpath('/presence').first
          p_attrs = presence_node.attributes
          Connfu::Event::Offer.new(:from => p_attrs['from'].value, :to => p_attrs['to'].value, :call_id => call_id)
        elsif node.xpath('//x:success', 'x' => 'urn:xmpp:ozone:say:complete:1').any?
          Connfu::Event::SayComplete.new(:call_id => call_id)
        elsif node.type == :result
          if (ref = node.xpath('x:ref', 'x' => 'urn:xmpp:ozone:1').first)
            Connfu::Event::Result.new(:call_id => call_id, :ref_id => ref.attributes['id'].value)
          else
            Connfu::Event::Result.new(:call_id => call_id)
          end
        elsif node.type == :error
          Connfu::Event::Error.new(:call_id => call_id)
        elsif node.xpath('//x:ringing', 'x' => 'urn:xmpp:ozone:1').any?
          Connfu::Event::Ringing.new(:call_id => call_id, :to => from, :from => to)
        elsif node.xpath('//x:answered', 'x' => 'urn:xmpp:ozone:1').any?
          Connfu::Event::Answered.new(:call_id => call_id)
        else
          self.transfer_complete?(node)
        end
      end

      def self.transfer_complete?(node)
        Connfu::TransferState.event_map.each do |k, v|
          if node.xpath("//x:#{k}", 'x' => 'urn:xmpp:ozone:transfer:complete:1').any?
            return v.new(:call_id => node.from.node)
          end
        end
      end
    end
  end
end