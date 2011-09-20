module Connfu
  module Dsl
    class CallBehaviour
      attr_reader :state

      STATES = [
        :started,
        :ringing,
        :answered,
        :hangup,
        :timeout,
        :rejected,
        :busy
      ]
      STATES.each do |state|
        const_set state.to_s.upcase, state
      end

      def on_start(&block)
        @state = STARTED
        @on_start = block if block_given?
        @on_start
      end

      def on_ringing(&block)
        @state = RINGING
        @on_ringing = block if block_given?
        @on_ringing
      end

      def on_answer(&block)
        @state = ANSWERED
        @on_answer = block if block_given?
        @on_answer
      end

      def on_hangup(&block)
        @state = HANGUP
        @on_hangup = block if block_given?
        @on_hangup
      end

      def on_reject(&block)
        @state = REJECTED
        @on_reject = block if block_given?
        @on_reject
      end

      def on_timeout(&block)
        @state = TIMEOUT
        @on_timeout = block if block_given?
        @on_timeout
      end

      def on_busy(&block)
        @state = BUSY
        @on_busy = block if block_given?
        @on_busy
      end
    end
  end
end
