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
        elsif transfer_complete?(:success, node)
          Connfu::Event::TransferSuccess.new(:call_id => call_id)
        elsif transfer_complete?(:timeout, node)
          Connfu::Event::TransferTimeout.new(:call_id => call_id)
        elsif transfer_complete?(:reject, node)
          Connfu::Event::TransferRejected.new(:call_id => call_id)
        elsif transfer_complete?(:busy, node)
          Connfu::Event::TransferBusy.new(:call_id => call_id)
        elsif node.type == :result
          Connfu::Event::Result.new(:call_id => call_id)
        elsif node.type == :error
          Connfu::Event::Error.new(:call_id => call_id)
        end
      end

      def self.transfer_complete?(kind, node)
        node.xpath("//x:#{kind}", 'x' => 'urn:xmpp:ozone:transfer:complete:1').any?
      end

      def self.transfer_complete2?(kind, node)
        nodes = node.xpath("//x:#{kind}", 'x' => 'urn:xmpp:ozone:transfer:complete:1')
        if nodes.any?
          node.first.from.node
        else
          nil
        end
      end

    end
  end
end