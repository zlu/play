module Connfu
  module Ozone
    module Parser

      def self.parse_event_from(node)
        call_id = node.from.node
        if node.xpath('//x:offer', 'x' => 'urn:xmpp:ozone:1').any?
          presence_node = node.xpath('/presence').first
          p_attrs = presence_node.attributes
          Connfu::Event::Offer.new(:from => p_attrs['from'].value, :to => p_attrs['to'].value, :call_id => call_id)
        elsif node.xpath('//x:success', 'x' => 'urn:xmpp:ozone:say:complete:1').any?
          Connfu::Event::SayComplete.new(:call_id => call_id)
        elsif node.type == :result
          Connfu::Event::Result.new(:call_id => call_id)
        elsif node.type == :error
          Connfu::Event::Error.new(:call_id => call_id)
        else
          self.transfer_complete?(node)
        end
      end

      def self.transfer_complete?(node)
        self.transfer_map.each do |k, v|
          if node.xpath("//x:#{k}", 'x' => 'urn:xmpp:ozone:transfer:complete:1').any?
            return v.new(:call_id => node.from.node)
          end
        end
      end

      private

      def self.transfer_map
        {
            :success => Connfu::Event::TransferSuccess,
            :timeout => Connfu::Event::TransferTimeout,
            :reject => Connfu::Event::TransferRejected,
            :busy => Connfu::Event::TransferBusy,
        }
      end
    end
  end
end