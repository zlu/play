%w[
  blather/client/client

  connfu/logger
  connfu/continuation
  connfu/commands
  connfu/event
  connfu/event_processor
  connfu/transfer_event
  connfu/dsl
  connfu/transfer_state
  connfu/ozone/parser
  connfu/connection_adaptor
].each { |file| require file }

module Connfu
  class << self
    attr_accessor :event_processor
    attr_accessor :connection
    attr_accessor :adaptor
  end

  def self.setup(host, password)
    @connection = Blather::Client.new.setup(host, password)
    @adaptor = Connfu::ConnectionAdaptor.new(@connection)
    @connection.register_handler(:ready, lambda { p 'Established @connection to Connfu Server' })
    [:iq, :presence].each do |stanza_type|
      @connection.register_handler(stanza_type) do |stanza|
        l.debug "Receiving #{stanza_type} from server"
        handle_stanza(stanza)
      end
    end
  end

  def self.handle_stanza(stanza)
    l.debug stanza
    event = Connfu::Ozone::Parser.parse_event_from(stanza)
    event_processor.handle_event(event)
  end

  def self.start(handler_class)
    self.event_processor ||= EventProcessor.new(handler_class)
    EM.run { @connection.run }
  end
end