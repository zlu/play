module Connfu
  module CallCommands
    @call_commands = ['accept', 'answer', 'hangup', 'reject']
    
    def redirect_iq(to)
      iq = Blather::Stanza::Iq.new(:set, to)
      Nokogiri::XML::Builder.with(iq) do |xml|
        xml.redirect("to" => to, "xmlns" => "urn:xmpp:ozone:1")
      end
      iq
    end

    def redirect(to)
      Connfu.connection.write redirect_iq(to)
    end

    @call_commands.each do |call_command|
      define_method :"#{call_command}_iq" do |to|
        iq = Blather::Stanza::Iq.new(:set, to)
        Nokogiri::XML::Builder.with(iq) do |xml|
          xml.send call_command, {"xmlns" => "urn:xmpp:ozone:1"}
        end
        iq
      end

      define_method :"#{call_command}" do
        l.info "#{call_command}"
        cc_iq = eval "#{call_command}_iq(\"#{Connfu.context.from.to_s}\")"
        Connfu.connection.write(cc_iq)
      end
    end
  end
end