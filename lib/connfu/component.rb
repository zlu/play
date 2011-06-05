module Connfu
  module Component
    def say_iq(text)
      iq = Blather::Stanza::Iq.new(:set, Connfu.context.values.first.from.to_s)
      Nokogiri::XML::Builder.with(iq) do |xml|
        xml.say_("xmlns" => "urn:xmpp:ozone:say:1") {
          xml.text text
        }
      end

      iq
    end

    def say(text) 
      l.info 'say'
      Connfu.connection.write say_iq(text)
    end
  end
end