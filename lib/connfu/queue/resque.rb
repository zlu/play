module Connfu
  module Queue
    class Resque
      extend ::Resque

      def self.clear
        redis.flushall
      end
    end
  end
end
