%w[
  rubygems
  blather
  blather/client/client
  parse_tree
  sexp_processor

  connfu/logger
  connfu/call_context
  connfu/verbs
  connfu/call_commands
  connfu/outbound_call
  connfu/iq_parser
  connfu/dsl_processor
  connfu/event
  connfu/error
  connfu/offer
  connfu/utils
  connfu/dsl
].each { |file| require file }

module Connfu
  @@base = nil
  @@dsl_processor = Connfu::DslProcessor.new

  def self.base
    @@base
  end

  def self.context=(context)
    @context = context
  end

  def self.context
    @context
  end

  def self.connection=(connection)
    @connection = connection
  end

  def self.connection
    @connection
  end

  def self.dsl_processor
    @@dsl_processor
  end

  def self.dsl_processor=(dp)
    @@dsl_processor = dp
  end

  def self.included(base)
    @@base = base
    base.extend Connfu::Dsl
    base.extend Connfu::Verbs
    base.extend Connfu::CallCommands
    base.extend Connfu::OutboundCall

    begin
      str = File.open(File.expand_path("../../examples/#{Connfu::Utils.underscore(base.to_s)}.rb", __FILE__)).readlines.join
      @@dsl_processor.process(ParseTree.new.parse_tree_for_string(str)[0])
    rescue
    end
  end

  def self.setup(host, password)
    @connection = Blather::Client.new.setup(host, password)
    @connection.register_handler(:ready, lambda { p 'Established @connection to Connfu Server' })
    @connection.register_handler(:iq) do |iq|
      l.debug 'Connfu#setup - register_handler(:iq)'
      l.debug iq
      Connfu::IqParser.parse iq
      Connfu::IqParser.fire_event
    end
  end

  def self.start
    @context ||= {}
    EM.run { @connection.run }
  end
end