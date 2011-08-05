module Connfu
  module Commands
    module StopComponent
      def call_jid
        super + "/" + @params[:ref_id]
      end

      def to_iq
        build_iq "xmlns" => rayo("ext:1")
      end
    end
  end
end