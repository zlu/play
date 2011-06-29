module Connfu
  class EventProcessor
    def initialize(handler_class)
      @handler_class = handler_class
    end

    def handle_event(event)
      handler_for(event).handle_event(event)
    end

    def handler_for(event)
      if event.is_a?(Connfu::Event::Offer)
        @handler = @handler_class.new(:from => event.presence_from, :to => event.presence_to)
      else
        @handler
      end
    end
  end
end