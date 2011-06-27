module Connfu
  module EventProcessor

    def self.handle_event_catching_waiting(event)
      catch :waiting do
        handle_event(event)
      end
    end

    def self.handle_event(event)
      case event
      when Connfu::Event::Offer
        Connfu.handler = Connfu.handler_class.new(:from => event.presence_from, :to => event.presence_to)
        Connfu.handler.run
      when Connfu::Event::SayComplete
        Connfu.handler.continue
      end
    end

  end
end