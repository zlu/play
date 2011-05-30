#require '../../lib/connfu/iq_parser'

module Connfu
  module Event
    class SayComplete < Blather::Stanza::Iq
      def self.import(node)
        super(node)
        Connfu::IqParser.fire_event
      end
    end
  end
end