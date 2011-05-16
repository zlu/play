require 'connfu'

module Connfu
  class Server

    def self.offer_call(client_jid)
      iq = Blather::Stanza::Iq.new(:set, client_jid, Blather::Stanza.next_id)
      Nokogiri::XML::Builder.with(iq) { |xml|
        xml.offer("xmlns"=>"urn:xmpp:ozone") {
          xml.say_ 'tel:+14157044517'
          xml.To 'tel:+14157044517'
          xml.From 'tel:+14155551212'
        }
      }

      iq
    end
  end
end