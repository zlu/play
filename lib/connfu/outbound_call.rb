module Connfu
  module OutboundCall
    def outbound_call_iq(to_domain, from_resource, to, from)
      oc_iq = Blather::Stanza::Iq.new(:set, to_domain)
      oc_iq.from = from_resource
      Nokogiri::XML::Builder.with(oc_iq) do |xml|
        xml.dial(:to => to, :from => from, "xmlns" => "urn:xmpp:ozone:1")
      end

      oc_iq
    end

    def dial(to)
      Connfu.connection.write outbound_call_iq('to_domain', 'from_resource', to, 'from')
    end
  end
end