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
      Connfu.connection.write say_iq(text)
    end

    def ask_iq(prompt)
      offer = Connfu.context.values.first
      ask_iq = Blather::Stanza::Iq.new(:set, offer.from.to_s)
      ask_iq.from = offer.to.to_s
      Nokogiri::XML::Builder.with(ask_iq) do |xml|
        xml.ask("xmlns" => "urn:xmpp:ozone:ask:1", "mode" => 'dtmf', "bargein" => 'false') do |xml|
          xml.prompt prompt
          xml.choices("content-type" => "application/grammar+voxeo") do |xml|
            xml.text '[4 DIGITS]'
          end
        end
      end

      ask_iq
    end

    def ask(prompt)
      Connfu.connection.write ask_iq(prompt)
    end

    def transfer_iq(to)
      iq = Blather::Stanza::Iq.new(:set, Connfu.context.values.first.from.to_s)
      Nokogiri::XML::Builder.with(iq) do |xml|
        xml.transfer("xmlns" => "urn:xmpp:ozone:transfer:1") {
          xml.to to
        }
      end

      iq
    end

    def transfer(to)
      Connfu.connection.write transfer_iq(to)
    end
  end
end