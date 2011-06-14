module Connfu
  module Event
    class SayComplete < Blather::Stanza::Iq
      def self.import(node)
        Connfu::IqParser.fire_event
        super(node)
      end
    end

    class AskComplete < Blather::Stanza::Iq
      def react
        concept = self.children.select{|n| n.name == 'complete'}.first[:concept]
        ah = Connfu.dsl_processor.ask_handler
        l.debug ah
        lasgn = ah.keys.first
        block = ah.values.first
        block.gsub!(lasgn, "\"#{concept}\"")
        Connfu.base.module_eval block
      end
    end

    class Result < Blather::Stanza::Iq  
      def self.create(node)
        node.reply!
      end
    end

    class OutboundResult < Blather::Stanza::Iq
      def self.import(node)
        update_context(node)
        super(node)
      end

      private

      def self.update_context(node)
        ref_node = node.xpath('/iq/ref').first
        call_id = ref_node.attributes['id'].value
        Connfu.outbound_context[call_id] = node
      end
    end
  end
end