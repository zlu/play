module Connfu
  module Dsl
    autoload :Methods, "connfu/dsl/methods"
    autoload :Recording, "connfu/dsl/recording"
    autoload :EventHandler, "connfu/dsl/event_handler"
    autoload :OutgoingCall, "connfu/dsl/outgoing_call"
    autoload :Commander, "connfu/dsl/commander"

    def self.included(base)
      base.send(:include, Connfu::Continuation)
      base.send(:include, Connfu::Dsl::Methods)
      base.send(:include, Connfu::Dsl::Recording)
      base.send(:include, Connfu::Dsl::EventHandler)
      base.send(:include, Connfu::Dsl::Commander)
      base.send(:include, Connfu::Logging)
      base.extend Connfu::Dsl::ClassMethods
      base.class_eval do
        attr_reader :outgoing_calls
        attr_accessor :last_event_call_id
      end
    end

    def on_offer(event=nil)
    end

    module ClassMethods
      def on_ready
        instance_eval(&@ready_block) if @ready_block
      end

      def on(context, &block)
        case context
          when :ready
            @ready_block = block
          when :offer
            define_method(:on_offer, &block)
          else
            raise "Unrecognised context: #{context}"
        end
      end

      def dial(options={}, &block)
        instance = new({})
        Connfu.event_processor.handlers << instance
        instance.create_outgoing_call(options, &block)
      end
    end

    def initialize(params)
      self.call_jid = params[:call_jid]
      self.client_jid = params[:client_jid]
      self.call_id = params[:call_id]
      @outgoing_calls = []
    end

    def create_outgoing_call(options)
      call = OutgoingCall.new(self)
      yield call if block_given?
      @outgoing_calls << call
      call.dial(options)
    end

    def handle_event(event)
      logger.debug "Handling event: %p" % event
      self.last_event_call_id = event.call_id

      if call = outgoing_calls.find { |c| c.can_handle_event?(event) }
        logger.debug "Dispatching event to call %p" % call
        call.handle_event(event)
      elsif waiting_for?(event)
        continue(event)
      else
        case event
          when Connfu::Event::Offer
            start do
              on_offer event
              hangup unless finished?
            end
          else
            logger.warn "Unrecognized event: %p" % event
        end
      end
    end

    def wait_because_of_tropo_bug_133
      Connfu.connection.wait_because_of_tropo_bug_133
    end

    def can_handle_event?(event)
      event_matches_call_id?(event) || 
      event_matches_last_command_id?(event) || 
      outgoing_calls.detect { |c| c.can_handle_event?(event) }
    end
  end
end