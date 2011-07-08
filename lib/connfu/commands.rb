module Connfu
  module Commands
    module Base
      def initialize(params)
        @params = params
      end

      def ==(other)
        other.kind_of?(self.class) && other.params == @params
      end

      def to
        @params[:to]
      end

      def from
        @params[:from]
      end

      def command
        self.class.name.split("::").last.downcase
      end

      def to_iq
        build_iq
      end

      protected

      def params
        @params
      end

      def build_iq(attributes = {}, &block)
        Connfu::Ozone::IqBuilder.build_iq(to, from, command, attributes, &block)
      end
    end

    class Dial
      include Base

      def to_iq
        oc_iq = Blather::Stanza::Iq.new(:set, Connfu.connection.jid.domain)
        oc_iq.from = Connfu.connection.jid.to_s
        Nokogiri::XML::Builder.with(oc_iq) do |xml|
          xml.dial_(:to => @params[:to], :from => @params[:from], "xmlns" => "urn:xmpp:ozone:1")
        end

        l.debug oc_iq
        oc_iq
      end
    end

    class Say
      include Base

      def text
        @params[:text]
      end

      def to_iq
        build_iq :xmlns => "urn:xmpp:ozone:say:1" do |xml|
          unless text.match(/^http:\/\/.*(.mp3|.wav)$/).nil?
            xml.audio('src' => text)
          else
            xml.text text
          end
        end
      end
    end

    class Answer
      include Base
    end

    class Accept
      include Base
    end

    class Reject
      include Base
    end

    class Hangup
      include Base
    end

    class Redirect
      include Base

      def to_iq
        build_iq 'to' => @params[:redirect_to]
      end
    end

    class Transfer
      include Base

      def to_iq
        attributes = {:xmlns => "urn:xmpp:ozone:transfer:1"}
        attributes[:timeout] = @params[:timeout] if @params[:timeout]

        build_iq attributes do |xml|
          @params[:transfer_to].each { |t| xml.to t }
        end
      end
    end
  end
end
