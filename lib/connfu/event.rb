#require '../../lib/connfu/iq_parser'

module Connfu
  module Event
    class SayComplete < Blather::Stanza::Iq
      def self.import(node)
        Connfu::IqParser.fire_event
        super(node)
      end
    end
  end
end