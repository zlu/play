module Connfu
  module Event
    class SayComplete < Blather::Stanza::Iq
      def self.import(node)
        Connfu::IqParser.fire_event
        super(node)
      end
    end

    class Result < Blather::Stanza::Iq
    end
  end
end