require 'connfu'

module Connfu
  class Commands

    def self.answer_iq(to)
      iq = Blather::Stanza::Iq.new(:set, to)
      Nokogiri::XML::Builder.with(iq) do |xml|
        xml.answer("xmlns" => "urn:xmpp:ozone:1")
      end
      iq
    end

    def self.answer(client)
      p 'inside of answer'
      p "answer to #{Connfu.context.from.to_s}"
      client.write answer_iq(Connfu.context.from.to_s)
    end

    def self.say_iq(to)
      iq = Blather::Stanza::Iq.new(:set, to)
      Nokogiri::XML::Builder.with(iq) do |xml|
        xml.say_("xmlns" => "urn:xmpp:ozone:say:1") {
          xml.speak "this is connfu"
        }
      end
      iq
    end

    def self.say(client)
      p 'inside of say'
      p Connfu.context
      p Connfu.context.from
      client.write say_iq(Connfu.context.from.to_s)
    end

  end
end