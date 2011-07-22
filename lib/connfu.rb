require 'blather/client/client'

module Connfu
  autoload :Continuation, 'connfu/continuation'
  autoload :Commands, 'connfu/commands'
  autoload :Dsl, 'connfu/dsl'
  autoload :Event, 'connfu/event'
  autoload :EventProcessor, 'connfu/event_processor'
  autoload :Jobs, 'connfu/jobs'
  autoload :Logging, 'connfu/logging'
  autoload :LoggingConnectionProxy, 'connfu/logging_connection_proxy'
  autoload :Ozone, 'connfu/ozone'
  autoload :Queue, 'connfu/queue'
  autoload :TransferState, 'connfu/transfer_state'

  include Connfu::Logging

  class << self
    attr_accessor :event_processor
    attr_accessor :connection
    attr_accessor :uri
  end

  def self.uri
    @uri || ENV['CONNFU_URI']
  end

  def self.handle_stanza(stanza)
    event = Connfu::Ozone::Parser.parse_event_from(stanza)
    event_processor.handle_event(event)
  end

  def self.start(handler_class)
    self.event_processor ||= EventProcessor.new(handler_class)
    EM.run do
      EventMachine::add_periodic_timer(1, Queue::Worker.new(Jobs::Dial.queue))
      connection.run
    end
  end

  def self.connection
    @connection ||= LoggingConnectionProxy.new(build_connection)
  end

  def self.build_connection
    parsed_uri = URI.parse(uri)

    Blather::Client.new.setup("#{parsed_uri.user}@#{parsed_uri.host}", parsed_uri.password).tap do |connection|
      [:iq, :presence].each do |stanza_type|
        connection.register_handler(stanza_type) do |stanza|
          logger.debug "Receiving #{stanza_type} from server"
          logger.debug stanza.inspect
          handle_stanza(stanza)
        end
      end

      connection.register_handler(:ready) do |stanza|
        logger.debug "Established @connection to Connfu Server with JID: #{uri}"
        logger.debug "Queue implementation: #{Queue.implementation.inspect}"
      end
    end
  end

  def self.logger
    @logger ||= Logger.new(STDOUT)
  end
end