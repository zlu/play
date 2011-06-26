module Connfu
  module CallCommands

    def redirect_iq(to)
      iq = Blather::Stanza::Iq.new(:set, Connfu.context.values.first.from)
      iq['from'] = Connfu.context.values.first.to
      Nokogiri::XML::Builder.with(iq) do |xml|
        xml.redirect("to" => to, "xmlns" => "urn:xmpp:ozone:1")
      end

      iq
    end

    def redirect(to)
      Connfu.connection.write redirect_iq(to)
    end

    def answer
      Connfu.adaptor.send_command Connfu::Commands::Answer.new(:to => server_address, :from => client_address)
      wait
    end

    def hangup
      l.debug '+++++++++++++++++++hangup'
      Connfu.adaptor.send_command Connfu::Commands::Hangup.new(:to => server_address, :from => client_address)
      wait
    end
  end
end