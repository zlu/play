module Connfu
  module Commands
    module Recording
      FORMATS = {
        :gsm => {
          :name => "GSM",
          :codecs => [:gsm]
        },
        :wav => {
          :name => "WAV",
          :codecs => [
            :linear_16bit_128k, :linear_16bit_256k, :alaw_pcm_64k, :mulaw_pcm_64k,
            :adpcm_32k, :adpcm_32k_oki, :g723_1b, :amr, :amr_wb, :g729_a, :evrc
          ]
        }
      }

      class InvalidEncoding < StandardError; end

      class Start
        include Connfu::Commands::Base

        def to_iq
          attributes = { "xmlns" => "urn:xmpp:ozone:record:1", "start-beep" => "true" }
          attributes["max-length"] = @params[:max_length] if @params[:max_length]
          attributes["start-beep"] = @params[:beep] if @params.has_key?(:beep)

          if @params.has_key?(:format)
            if FORMATS.has_key?(@params[:format])
              format = FORMATS[@params[:format]]
              attributes["format"] = format[:name]

              if @params.has_key?(:codec)
                if format[:codecs].include?(@params[:codec])
                  attributes["codec"] = @params[:codec].to_s.upcase
                else
                  raise InvalidEncoding, "Codec #{@params[:codec]} not supported for #{@params[:format]} format"
                end
              end

            else
              raise InvalidEncoding, "Format #{@params[:format]} not supported"
            end
          end

          if @params.has_key?(:codec) && !@params.has_key?(:format)
            raise InvalidEncoding, "Please supply :format when specifying :codec"
          end

          build_iq(attributes)
        end

        def command
          "record"
        end
      end

      class Stop
        include Connfu::Commands::Base

        def to
          super + "/" + @params[:ref_id]
        end

        def to_iq
          build_iq "xmlns" => "urn:xmpp:ozone:ext:1"
        end
      end
    end
  end
end