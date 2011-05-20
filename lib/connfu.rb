%w[
  rubygems
  blather
  blather/client/client
  awesome_print

  connfu/verbs
  connfu/call_commands
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
    @connection = Blather::Client.new.setup(host, password)
    @connection.register_handler(:ready, lambda { p 'Established @connection to Connfu Server' })
    @connection.register_handler(:iq) do |offer_iq|
      l.info 'Connfu#setup - register_handler(iq)'
      l.info offer_iq
      if offer_iq && offer_iq.children.length > 0 && offer_iq.children[0].name == 'offer'
        l.info 'inside offer iq'
        self.context = offer_iq

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
      l.info "self.saved"
      @@saved
    end

    def on(context, &block)
      l.info "on"
      @@saved = {context => block}
    end
  end
end