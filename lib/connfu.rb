%w[
  rubygems
  blather
  blather/client/client

  connfu/logger
  connfu/continuation
  connfu/ozone
  connfu/component
  connfu/commands
  connfu/call_commands
  connfu/event
  connfu/dsl
  connfu/iq_parser
  connfu/connection_adaptor
].each { |file| require file }

module Connfu
  class << self
    attr_accessor :handler_class
    attr_accessor :handler
    attr_accessor :connection
    attr_accessor :adaptor
  end

  def self.setup(host, password)
    @connection = Blather::Client.new.setup(host, password)
    @adaptor = Connfu::ConnectionAdaptor.new(@connection)
    @connection.register_handler(:ready, lambda { p 'Established @connection to Connfu Server' })
    [:iq, :presence].each do |stanza|
      @connection.register_handler(stanza) do |msg|
        l.debug "Receiving #{stanza} from server"
        l.debug msg
        Connfu::IqParser.parse msg
      end
    end
  end

  def self.start(handler_class)
    @handler_class = handler_class
    EM.run { @connection.run }
  end
end