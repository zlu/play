module Connfu
  module Continuation

    def continue
      @continuation.call
    end

    private

    def wait
      callcc do |cc|
        @continuation = cc
        throw :waiting
      end
    end
  end
end