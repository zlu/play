module Connfu
  module Dsl
    module Commander
      def send_command_without_waiting(command)
        @last_command_id = Connfu.connection.send_command command
        logger.debug "Sent command: %p" % command
      end

      def send_command(command)
        return if @finished
        send_command_without_waiting command
        result = wait_for Connfu::Event::Result, Connfu::Event::Error
        logger.debug "Result from command: %p" % result
        if result.is_a?(Connfu::Event::Error)
          raise
        else
          result
        end
      end

      private

      def waiting_for?(event)
        can_handle_event?(event) && @waiting_for && @waiting_for.detect do |e|
          e === event
        end
      end

      def wait_for(*events)
        @waiting_for = events
        wait
      end
    end
  end
end