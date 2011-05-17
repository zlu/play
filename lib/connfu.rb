%w[
  rubygems
  blather/client/client
  blather/client/dsl
  awesome_print

  connfu/commands
  connfu/offer
  connfu/credentials
  connfu/utils
].each { |file| require file }

module Connfu

  @@saved ||= []

  def self.included(base)
    base.extend ClassMethods
  end

  def self.setup(host, password)
    connection = Blather::Client.new.setup(host, password)
    connection.register_handler(:ready, lambda { p 'Established connection to Connfu Server' })
    connection.register_handler(:iq) do
      p 'inside of register iq handler'
      p ClassMethods::saved
      ClassMethods::saved.each do |elem|
        elem.call(connection)
      end
    end
    @connection = connection
    connection
  end

  def self.start(connection)
    EM.run { connection.run }
  end

  module ClassMethods
    def saved=(c, &b)
      @saved ||= {}
      @saved[c] = b
    end

    def self.saved
      @saved
    end

    def on(context, &block)
      saved=(context, block)
    end
  end

end