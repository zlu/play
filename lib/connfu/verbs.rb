require 'connfu'

module Connfu
  module Verbs
    l.info 'in Connfu::Verbs'
    
    def answer_iq(to)
      iq = Blather::Stanza::Iq.new(:set, to)
      Nokogiri::XML::Builder.with(iq) do |xml|
        xml.answer("xmlns" => "urn:xmpp:ozone:1")
      end
      iq
    end

    def answer
      l.info 'answer'
      Connfu.connection.write answer_iq(Connfu.context.from.to_s)
    end

    def say_iq(to, text)
      iq = Blather::Stanza::Iq.new(:set, to)
      Nokogiri::XML::Builder.with(iq) do |xml|
        xml.say_("xmlns" => "urn:xmpp:ozone:say:1") {
          xml.speak text
        }
      end
      iq
    end

    def say(text)
      l.info 'say'
      Connfu.connection.write say_iq(Connfu.context.from.to_s, text)
    end
  end
end