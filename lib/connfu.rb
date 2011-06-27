%w[
  rubygems
  blather
  blather/client/client
  parse_tree
  sexp_processor
  ruby2ruby

  connfu/logger
  connfu/call_context
  connfu/call_handler
  connfu/ozone
  connfu/component
  connfu/commands
  connfu/call_commands
  connfu/outbound_call
  connfu/iq_parser
  connfu/event
  connfu/offer
  connfu/utils
  connfu/dsl
  connfu/call
  connfu/connection_adaptor
].each { |file| require file }

module Connfu
  @@base = nil

  def self.base
    @@base
  end

  class << self
    attr_accessor :handler_class
    attr_accessor :handler
    attr_accessor :connection
    attr_accessor :context
    attr_accessor :adaptor
    attr_accessor :conference_handlers
    attr_accessor :outbound_calls
    attr_accessor :outbound_context
  end

  def self.setup(host, password)
    @context ||= {}
    @outbound_context ||= {}
    @conference_handlers ||= []
    @outbound_calls ||= {}
    @connection = Blather::Client.new.setup(host, password)
    @adaptor = Connfu::ConnectionAdaptor.new(@connection)
    @connection.register_handler(:ready, lambda { p 'Established @connection to Connfu Server' })
    [:iq, :presence].each do |stanza|
      @connection.register_handler(stanza) do |msg|
        l.debug "Receiving #{stanza} from server"
        l.debug msg
        l.debug msg.class
        Connfu::IqParser.parse msg
      end
    end
  end

  def self.start(handler_class)
    @handler_class = handler_class
    EM.run { @connection.run }
  end
end