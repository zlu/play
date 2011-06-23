%w[
  rubygems
  blather
  blather/client/client
  parse_tree
  sexp_processor
  ruby2ruby

  connfu/logger
  connfu/call_context
  connfu/component
  connfu/call_commands
  connfu/outbound_call
  connfu/iq_parser
  connfu/dsl_processor
  connfu/event
  connfu/offer
  connfu/utils
  connfu/dsl
  connfu/call
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

  def self.outbound_context=(context)
    @outbound_context = context
  end

  def self.outbound_context
    @outbound_context
  end

  def self.outbound_calls=(calls)
    @outbound_calls = calls
  end

  def self.outbound_calls
    @outbound_calls
  end

  def self.connection=(connection)
    @connection = connection
  end

  def self.connection
    @connection
  end

  def self.conference_handlers=(ch)
    @conference_handlers = ch
  end
  
  def self.conference_handlers
    @conference_handlers
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
    base.extend Connfu::Component
    base.extend Connfu::CallCommands
    base.extend Connfu::OutboundCall

    begin
      str = File.open(File.expand_path("../../examples/#{Connfu::Utils.underscore(base.to_s)}.rb", __FILE__)).readlines.join
      @@dsl_processor.process(ParseTree.new.process(str))
    rescue
    end
  end

  def self.setup(host, password)
    @context ||= {}
    @outbound_context ||= {}
    @conference_handlers ||= []
    @outbound_calls ||= {}
    @connection = Blather::Client.new.setup(host, password)
    @connection.register_handler(:ready, lambda { p 'Established @connection to Connfu Server' })
    [:iq, :presence].each do |stanza|
      @connection.register_handler(stanza) do |msg|
        l.debug "Receiving #{stanza} from server"
        l.debug msg
        catch :finished do
          Connfu::IqParser.parse msg
        end
        
      end
    end
  end

  def self.start
    EM.run { @connection.run }
  end
end