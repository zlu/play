module Connfu
  module Event
    class Presence
      attr_reader :call_id

      def initialize(params = {})
        @call_id = params[:call_id]
      end
    end

    class Offer < Presence

      attr_reader :presence_from, :presence_to

      def initialize(params)
        @presence_from = params[:from]
        @presence_to = params[:to]
        @call_id = params[:call_id]
      end
    end

    class SayComplete < Presence
    end

    class TransferSuccess < Presence
    end

    class TransferTimeout < Presence
    end

    class Result
    end
  end
end