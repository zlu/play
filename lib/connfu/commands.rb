module Connfu
  module Commands
    class Base
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
        iq = Blather::Stanza::Iq.new(:set, to)
        iq['from'] = from
        Nokogiri::XML::Builder.with(iq) do |xml|
          xml.send "#{command}_", {"xmlns" => "urn:xmpp:ozone:1"}.merge(attributes), &block
        end

        iq
      end
    end

    class Say < Base
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

    class Answer < Base
    end

    class Accept < Base
    end

    class Reject < Base
    end

    class Hangup < Base
    end

    class Redirect < Base
      def to_iq
        build_iq 'to' => @params[:redirect_to]
      end
    end

    class Transfer < Base
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
