module Connfu
  module Commands
    class Base
      def initialize(params)
        @params = params
      end

      def ==(other)
        other.kind_of?(self.class) &&
          other.params == @params
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
  end
end
