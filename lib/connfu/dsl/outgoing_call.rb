module Connfu
  module Dsl
    class OutgoingCall
      include Connfu::Dsl::EventHandler
      include Connfu::Dsl::Methods
      include Connfu::Dsl::Recording
      include Connfu::Dsl::Commander
      include Connfu::Continuation
      include Connfu::Logging

      def initialize(handler)
        @handler = handler
        @call_id = nil
        @behaviours = {}
      end

      def on_start(&block)
        @behaviours[:start] = block if block_given?
      end

      def on_ringing(&block)
        @behaviours[:ringing] = block if block_given?
      end

      def on_answer(&block)
        @behaviours[:answer] = block if block_given?
      end

      def on_hangup(&block)
        @behaviours[:hangup] = block if block_given?
      end

      def can_handle_event?(event)
        event_matches_call_id?(event) || event_matches_last_command_id?(event)
      end

      def handle_event(event)
        logger.debug "Call handling event %p" % event
        if expected_dial_result?(event)
          logger.debug "expected a dial result, got one."
          self.call_id = event.ref_id
          run_any_call_behaviour_for(:start)
        elsif waiting_for?(event)
          continue(event)
        else
          case event
            when Connfu::Event::Ringing
              logger.debug "Setting call and client jids"
              self.client_jid = event.presence_to
              self.call_jid = event.presence_from
              run_any_call_behaviour_for(:ringing)
            when Connfu::Event::Answered
              @handler.wait_because_of_tropo_bug_133
              run_any_call_behaviour_for(:answer)
            when Connfu::Event::Hangup
              run_any_call_behaviour_for(:hangup)
              @finished = true
            else
              logger.warn "Unrecognized event: %p" % event
          end
        end
      end

      def dial(options)
        options = {
          :to => options[:to],
          :from => options[:from],
          :headers => options[:headers],
          :client_jid => Connfu.connection.jid.to_s,
          :rayo_host => Connfu.connection.jid.domain
        }
        options.delete(:headers) if options[:headers].nil?
        @handler.send_command_without_waiting Connfu::Commands::Dial.new(options)
      end

      private

      def expected_dial_result?(event)
        event.is_a?(Connfu::Event::Result) && waiting_for_dial_result?
      end

      def waiting_for_dial_result?
        @call_id.nil?
      end

      def run_any_call_behaviour_for(event_name)
        if behaviour = @behaviours[event_name]
          start { instance_eval(&behaviour) }
        end
      end
    end
  end
end