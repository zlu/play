module Connfu
  class Offer < Blather::Stanza::Iq
    def self.result_for_node(node)
      result_iq = Blather::Stanza::Iq.new(:result, node.from, node.id)
      result_iq.from = node.to
#      l.debug 'sending to server'
#      l.debug result_iq
      result_iq
    end

    def self.import(node)
      jid = Blather::JID.new(node.from)
      Connfu.context[jid.node] = node
      super(node).tap {Connfu.connection.write result_for_node(node)}
    end
  end
end