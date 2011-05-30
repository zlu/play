%w[
  rubygems
  blather
  blather/client/client
  parse_tree
  sexp_processor

  connfu/logger
  connfu/verbs
  connfu/call_commands
  connfu/iq_parser
  connfu/dsl_processor
  connfu/event
  connfu/error
  connfu/offer
  connfu/utils
].each { |file| require file }

module Connfu
  #TODO initialized twice, why?
  l.info 'Connfu'

  @@base = nil
  @@dsl_processor = Connfu::DslProcessor.new

  def self.base
    @@base
  end

  def self.context=(offer_iq)
    @context = offer_iq
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
    base.extend ClassMethods
    base.extend Connfu::Verbs
    base.extend Connfu::CallCommands
  end

  def self.setup(host, password)
    str = File.open(File.expand_path('../../examples/answer_example.rb', __FILE__)).readlines.join
    @@dsl_processor.process(ParseTree.new.parse_tree_for_string(str)[0])

    @connection = Blather::Client.new.setup(host, password)
    @connection.register_handler(:ready, lambda { p 'Established @connection to Connfu Server' })
    @connection.register_handler(:iq) do |iq|
      l.debug 'Connfu#setup - register_handler(:iq)'
      parsed = Connfu::IqParser.parse iq
      @context = parsed
      Connfu::IqParser.fire_event
    end
  end

  def self.start
    EM.run { @connection.run }
  end

  module ClassMethods
    def on(context, &block)
      l.info "on"
    end
  end
end