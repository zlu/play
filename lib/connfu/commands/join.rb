module Connfu
  module Commands
    class Join
      include Base

      def to_iq
        oc_iq = Blather::Stanza::Iq.new(:set, to)
        oc_iq.from = from
        Nokogiri::XML::Builder.with(oc_iq) do |xml|
          xml.join_("xmlns" => rayo('1'), :direction => "duplex", :media => "bridge", :"call-id" => @params[:call_id])
        end
        
        oc_iq
      end
    end
  end
end