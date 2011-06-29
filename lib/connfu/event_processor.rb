module Connfu
  class EventProcessor
    def initialize(handler_class)
      @handler_class = handler_class
    end

    def handle_event(event)
      callcc do |resume|
        # Because the event handling code uses continuations, when
        # it returns the call stack can be from a previous call to
        # handle_event.  Once the event has been handled, we need
        # to force it back to the latest call stack, or all manner
        # of strangeness can occur
        @latest_resume = resume
        handler_for(event).handle_event(event)
        @latest_resume.call
      end
    end

    def handler_for(event)
      if event.is_a?(Connfu::Event::Offer)
        Connfu.handler = @handler_class.new(:from => event.presence_from, :to => event.presence_to)
      else
        Connfu.handler
      end
    end
  end
end