module Connfu
  module CallHandler
    def handle(event)
      continue
    end

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