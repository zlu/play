module Connfu
  module Continuation

    def continue(result=nil)
      @continuation.call result
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