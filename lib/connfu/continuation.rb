module Connfu
  module Continuation
    def continue(result = nil)
      continuation = @continuation
      @continuation = nil
      continuation.call result if continuation
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