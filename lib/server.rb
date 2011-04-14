require 'connfu'

module Ozone
  include Credentials
  @client_jid = CLIENT_JID

  def self.offer
    iq = Blather::Stanza::Iq.new(:set, @client_jid, Blather::Stanza.next_id)
    Nokogiri::XML::Builder.with(iq) { |xml|
      xml.offer("xmlns"=>"urn:xmpp:ozone") {
        xml.say 'tel:+14157044517'
        xml.To 'tel:+14157044517'
        xml.From 'tel:+14155551212'
      }
    }
    iq
  end
end