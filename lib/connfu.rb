%w[
  blather/client/client

  connfu/logger
  connfu/continuation
  connfu/event
  connfu/event_processor
  connfu/transfer_event
  connfu/dsl
  connfu/transfer_state
  connfu/ozone/parser
  connfu/ozone/iq_builder
  connfu/logging_connection_proxy
  connfu/commands/base
  connfu/queue
  connfu/queue/worker
  connfu/queue/in_process
  connfu/jobs
].each { |file| require file }

Dir[File.expand_path("../connfu/commands/**/*.rb", __FILE__)].each do |f|
  require f
end

module Connfu
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
          l.debug "Receiving #{stanza_type} from server"
          l.debug stanza.inspect
          handle_stanza(stanza)
        end
      end

      connection.register_handler(:ready) do |stanza|
        l.debug "Established @connection to Connfu Server with JID: #{uri}"
        l.debug "Queue implementation: #{Queue.implementation.inspect}"
      end
    end
  end
end