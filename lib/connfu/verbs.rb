module Connfu
  module Verbs
    def say_iq(to, text)
      iq = Blather::Stanza::Iq.new(:set, to)
      Nokogiri::XML::Builder.with(iq) do |xml|
        xml.say_("xmlns" => "urn:xmpp:ozone:say:1") {
          xml.text text
        }
      end

      iq
    end

    def say(text)
      l.info 'say'
      l.debug Connfu.context
      Connfu.connection.write say_iq(Connfu.context.values.first.from.to_s, text)
    end
  end
end