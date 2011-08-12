module Connfu
  class EventProcessor
    include Connfu::Logging

    attr_reader :handler_class

    def initialize(handler_class)
      @handler_class = handler_class
    end

    def handle_event(event)
      logger.debug "Incoming event: %p" % event
      if handler = handler_for(event)
        logger.debug "Passing event to handler: %p" % handler
        handler.handle_event(event)
      elsif event.is_a?(Connfu::Event::Offer)
        handler = build_handler(event)
        handlers << handler
        handler.handle_event(event)
      end
      remove_finished_handlers
    end

    def handlers
      @handlers ||= []
    end

    private

    def build_handler(event)
      @handler_class.new(:call_jid => event.presence_from, :client_jid => event.presence_to, :call_id => event.call_id)
    end

    def handler_for(event)
      handlers.detect do |h|
        logger.debug "asking %p" % h
        h.can_handle_event?(event)
      end
    end

    def remove_finished_handlers
      handlers.delete_if(&:finished?)
    end
  end
end