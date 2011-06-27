module Connfu
  module Event
    class Offer

      attr_reader :presence_from, :presence_to

      def initialize(params)
        @presence_from = params[:from]
        @presence_to = params[:to]
      end
    end

    class Result
    end

    class SayComplete
    end
  end
end