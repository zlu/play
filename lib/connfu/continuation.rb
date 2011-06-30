module Connfu
  module Continuation
    def start
      continue_with lambda {run}
    end

    def continue(result = nil)
      if continuation = @continuation
        @continuation = nil
        continue_with(continuation, result)
      end
    end

    def continue_with(next_step, result = nil)
      callcc do |caller|
        @latest_caller = caller
        catch :waiting do
          next_step.call(result)
        end
        @latest_caller.call
      end
    end

    def wait
      callcc do |cc|
        @continuation = cc
        throw :waiting
      end
    end
  end
end
