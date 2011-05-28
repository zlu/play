%w[
  rubygems
  blather
  blather/client/client
  parse_tree
  sexp_processor

  connfu/verbs
  connfu/event
  connfu/call_commands
  connfu/iq_parser
  connfu/dsl_processor
  connfu/error
  connfu/offer
  connfu/utils
  connfu/logger
].each { |file| require file }

module Connfu
  #TODO initialized twice, why?
  l.info 'Connfu'

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

  def self.included(base)
    base.extend ClassMethods
    base.extend Connfu::Verbs
    base.extend Connfu::CallCommands
  end

  def self.setup(host, password)
    str = File.open(File.expand_path('../../examples/answer_example.rb', __FILE__)).readlines.join
    Connfu::DslProcessor.new.process(ParseTree.new.parse_tree_for_string(str)[0])

    @connection = Blather::Client.new.setup(host, password)
    @connection.register_handler(:ready, lambda { p 'Established @connection to Connfu Server' })
    @connection.register_handler(:iq) do |iq|
      l.info 'Connfu#setup - register_handler(iq)'
      parsed = Connfu::IqParser.parse(iq)
      l.debug parsed
      l.debug parsed.class.name
      if iq && iq.children.length > 0 && iq.children[0].name == 'offer'
        l.info 'offer iq'
        self.context = iq

        ClassMethods.saved.each do |k, v|
          v.call(@connection)
        end
      end
    end
  end

  def self.start
    EM.run { @connection.run }
  end

  module ClassMethods
    def self.saved
      @@saved
    end

    def on(context, &block)
      l.info "on"
      @@saved = {context => block}
    end
  end
end