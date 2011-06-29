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
        handle_event_without_resume(event)
        @latest_resume.call
      end
    end

    def handle_event_without_resume(event)
      catch :waiting do
        case event
          when Connfu::Event::Offer
            Connfu.handler = @handler_class.new(:from => event.presence_from, :to => event.presence_to)
            Connfu.handler.run
          when Connfu::Event::SayComplete
            Connfu.handler.continue
          when Connfu::Event::TransferSuccess
            Connfu.handler.continue(true)
          when Connfu::Event::TransferTimeout
            Connfu.handler.continue(false)
        end
      end
    end
  end
end