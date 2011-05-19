%w[
  rubygems
  blather
  blather/client/client
  blather/client/dsl
  awesome_print

  connfu/verbs
  connfu/offer
  connfu/credentials
  connfu/utils
  connfu/logger
].each { |file| require file }

module Connfu

  @context
  @connection

  def self.context=(offer_iq)
    @context = offer_iq
  end

  def self.context
    @context
  end

  def self.connection
    @connection
  end

  def self.included(base)
    base.extend ClassMethods
    base.extend Connfu::Verbs
  end

  def self.setup(host, password)
    connection = Blather::Client.new.setup(host, password)
    connection.register_handler(:ready, lambda { p 'Established connection to Connfu Server' })
    connection.register_handler(:iq) do |offer_iq|
      l.info 'inside of register iq handler'
      l.info offer_iq
      l.info offer_iq.children[0]
      if offer_iq.children.length > 0 && offer_iq.children[0].name == 'offer'
        l.info 'inside offer iq'
        self.context = offer_iq

        ClassMethods.saved.each do |k, v|
          v.call(connection)
        end
      end

      if offer_iq.children.length > 0 && offer_iq.children[0].name == 'offer'
        l.info 'inside answer result iq'
      end
    end
    @connection = connection
    connection
  end

  def self.start(connection)
    EM.run { connection.run }
  end

  module ClassMethods
    @@saved = {}

    #TODO initialized twice, why?
    l.info "saved initialized...#{@@saved.object_id}"

    def self.saved
      l.info @@saved.object_id
      @@saved
    end

    def save_me(context, &block)
      l.info "inside of save_me #{context}"
      p @@saved.object_id
      @@saved = {context => block}
    end

    def on(context, &block)
      "inside of on method #{@@saved.object_id}"
      save_me(context, &block)
    end
  end
end