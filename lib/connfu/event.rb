module Connfu
  module Event


    class Offer
      attr_reader :presence_from, :presence_to
      def initialize(params)
        @presence_from = params[:from]
        @presence_to = params[:to]
      end
    end

    class Result
    end

    class SayComplete
    end

    # class SayComplete < Blather::Stanza::Iq
    #   def self.import(node)
    #     super(node)
    #   end
    # end
    # 
    class AskComplete < Blather::Stanza::Iq
      def react
        concept = self.children.select { |n| n.name == 'complete' }.first[:concept]
      end
    end

    # class Result < Blather::Stanza::Iq
    #   def self.create(node)
    #     node.reply!
    #   end
    # end

    class OutboundResult < Blather::Stanza::Iq
      def self.import(node)
        update_context(node)
        super(node)
      end

      private

      def self.update_context(node)
        ref_node = node.xpath('//oc:ref', 'oc' => 'urn:xmpp:ozone:1').first
        call_id = ref_node.attributes['id'].value
        Connfu.outbound_context[call_id] = node
      end
    end

    class Ringing < Blather::Stanza::Iq
      def self.import(node)
        Connfu::Call.update_state(node, :ringing)
        super(node)
      end
    end

    class Answered < Blather::Stanza::Iq
      def self.import(node)
        conf = Connfu.conference_handlers.shift
        unless conf.nil?
          conf.attributes['to'].value = Connfu.outbound_context.keys.first
          Connfu.connection.write(conf.to_xml) unless conf.nil?
        end

        Connfu::Call.update_state(node, :answered)
        super(node)
      end
    end

    class End < Blather::Stanza::Iq
      
    end
  end
end