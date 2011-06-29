module Connfu
  class EventProcessor
    def initialize(handler_class)
      @handler_class = handler_class
    end

    def handle_event(event)
      if event && event.respond_to?(:call_id) && h = handler_for(event)
        h.handle_event(event)
      end
    end

    private

    def handler_for(event)
      if event.is_a?(Connfu::Event::Offer)
        handlers[event.call_id] = @handler_class.new(:from => event.presence_from, :to => event.presence_to)
      else
        handlers[event.call_id]
      end
    end

    def handlers
      @handlers ||= {}
    end
  end
end