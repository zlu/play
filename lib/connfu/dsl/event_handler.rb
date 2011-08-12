module Connfu
  module Dsl
    module EventHandler
      def call_jid=(jid)
        @call_jid ||= jid
      end

      def client_jid=(jid)
        @client_jid ||= jid
      end

      def call_id=(id)
        @call_id ||= id
      end

      def finished?
        @finished == true
      end

      def can_handle_event?(event)
        event_matches_call_id?(event) || event_matches_last_command_id?(event)
      end

      def observe_events_for(call_id)
        observed_call_ids << call_id
      end

      def handle_event(event)
        # no-op
      end

      private

      def event_matches_call_id?(event)
        event.call_id == call_id || observed_call_ids.include?(event.call_id)
      end

      def event_matches_last_command_id?(event)
        event.respond_to?(:command_id) && @last_command_id == event.command_id
      end

      def observed_call_ids
        @observed_call_ids ||= []
      end
    end
  end
end