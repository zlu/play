module Connfu
  module Commands

    class Ask
      include Connfu::Commands::Base

      def prompt
        @params[:prompt]
      end

      def digits
        @params[:digits]
      end

      def build_iq
        attributes = { "xmlns" => tropo('ask:1'), "mode" => "dtmf", "terminator" => "#" }
        super(attributes) do |xml|
          xml.prompt do |p|
            p.text prompt
          end
          xml.choices("content-type" => "application/grammar+voxeo") do |c|
            c.text "[#{digits} DIGITS]"
          end
        end
      end
    end

  end
end