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

      protected

      def params
        @params
      end
    end

    class Say < Base
      def text
        @params[:text]
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
      def redirect_to
        @params[:redirect_to]
      end
    end

    class Transfer < Base
      def transfer_to
        @params[:transfer_to]
      end
    end
  end
end
