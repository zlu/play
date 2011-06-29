module Connfu
  module Ozone
    def iq_from_command(command)
      case command
        when Connfu::Commands::Answer
          answer_iq(command.to, command.from)
        when Connfu::Commands::Accept
          accept_iq(command.to, command.from)
        when Connfu::Commands::Reject
          reject_iq(command.to, command.from)
        when Connfu::Commands::Hangup
          hangup_iq(command.to, command.from)
        when Connfu::Commands::Say
          say_iq(command.text, command.to, command.from)
        when Connfu::Commands::Redirect
          redirect_iq(command.redirect_to, command.to, command.from)
        when Connfu::Commands::Transfer
          transfer_iq(command.transfer_to, command.to, command.from, command.timeout)
      end
    end

    extend self

    private

    CALL_COMMANDS = ['accept', 'answer', 'hangup', 'reject']

    CALL_COMMANDS.each do |call_command|
      define_method :"#{call_command}_iq" do |to, from|
        build_iq(call_command, to, from)
      end
    end

    def redirect_iq(redirect_to, to, from)
      build_iq 'redirect', to, from, 'to' => redirect_to
    end

    def transfer_iq(transfer_to, to, from, timeout)
      attributes = {:xmlns => "urn:xmpp:ozone:transfer:1"}
      attributes[:timeout] = timeout if timeout

      build_iq 'transfer', to, from, attributes do |xml|
        transfer_to.each { |t| xml.to t }
      end
    end

    def say_iq(text, to, from)
      build_iq 'say_', to, from, :xmlns => "urn:xmpp:ozone:say:1" do |xml|
        unless text.match(/^http:\/\/.*(.mp3|.wav)$/).nil?
          xml.audio('src' => text)
        else
          xml.text text
        end
      end
    end

    def build_iq(command, to, from, attributes = {}, &block)
      iq = Blather::Stanza::Iq.new(:set, to)
      iq['from'] = from
      Nokogiri::XML::Builder.with(iq) do |xml|
        xml.send command, {"xmlns" => "urn:xmpp:ozone:1"}.merge(attributes), &block
      end

      iq
    end
  end
end