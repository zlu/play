module Connfu
  module Ozone
    def say_iq(text, to)
      iq = Blather::Stanza::Iq.new(:set, to)
      Nokogiri::XML::Builder.with(iq) do |xml|
        xml.say_("xmlns" => "urn:xmpp:ozone:say:1") {
          unless text.match(/^http:\/\/.*(.mp3|.wav)$/).nil?
            xml.audio('src' => text)
          else
            xml.text text
          end
        }
      end

      iq
    end

    def iq_from_command(command)
      case command
      when Connfu::Commands::Answer
        answer_iq(command.to, command.from)
      when Connfu::Commands::Say
        say_iq(command.text, command.to)
      end
    end

    extend self
    
    private
    
    CALL_COMMANDS = ['accept', 'answer', 'hangup', 'reject']
    
    CALL_COMMANDS.each do |call_command|
      define_method :"#{call_command}_iq" do |to, from|
        iq = Blather::Stanza::Iq.new(:set, to)
        iq['from'] = from
        Nokogiri::XML::Builder.with(iq) do |xml|
          xml.send call_command, {"xmlns" => "urn:xmpp:ozone:1"}
        end

        iq
      end
    end
    
  end
end