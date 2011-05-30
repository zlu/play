module Connfu
  module CallCommands
    @call_commands = ['accept', 'answer', 'hangup', 'reject']
    
    def redirect_iq(to, from)
      iq = Blather::Stanza::Iq.new(:set, to)
      iq['from'] = from
      Nokogiri::XML::Builder.with(iq) do |xml|
        xml.redirect("to" => to, "xmlns" => "urn:xmpp:ozone:1")
      end
      iq
    end

    def redirect(to, from)
      Connfu.connection.write redirect_iq(to, from)
    end

    @call_commands.each do |call_command|
      define_method :"#{call_command}_iq" do |to, from|
        iq = Blather::Stanza::Iq.new(:set, to)
        iq['from'] = from
        Nokogiri::XML::Builder.with(iq) do |xml|
          xml.send call_command, {"xmlns" => "urn:xmpp:ozone:1"}
        end

        iq
      end

      define_method :"#{call_command}" do
        l.info "#{call_command}"
        cc_iq = eval "#{call_command}_iq(\"#{Connfu.context.from.to_s}\", \"#{Connfu.context.to.to_s}\")"
        l.debug 'sending to server =>>>>'
        l.debug cc_iq
        Connfu.connection.write(cc_iq)
      end
    end
  end
end