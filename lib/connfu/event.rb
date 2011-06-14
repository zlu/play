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
      
    end
  end
end