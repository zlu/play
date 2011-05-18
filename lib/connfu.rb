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
  end

  def self.setup(host, password)
    connection = Blather::Client.new.setup(host, password)
    connection.register_handler(:ready, lambda { p 'Established connection to Connfu Server' })
    connection.register_handler(:iq) do |offer_iq|
      p 'inside of register iq handler'
      p offer_iq
      p offer_iq.children
      p offer_iq.children[0]
      if offer_iq.children.length > 0 && offer_iq.children[0].name == 'offer'
        p 'inside offer iq'
        self.context = offer_iq

        p ClassMethods.saved.object_id
        ClassMethods.saved.each do |k, v|
          p k
          p v
          v.call(connection)
        end
      end

      if offer_iq.children.length > 0 && offer_iq.children[0].name == 'offer'
        p 'inside answer result iq'
        
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
    p "saved initialized...#{@@saved.object_id}"

    def self.saved
      p self
      p @@saved.object_id
      @@saved
    end

    def save_me(context, &block)
      p "inside of save_me #{context}"
      p self
      @@saved = {context => block}
      p @@saved.object_id
      p @@saved.inspect
    end

    def on(context, &block)
      p self
      save_me(context, &block)
      p "inside of on method #{@@saved.object_id}"
    end

    def answer_iq(to)
      iq = Blather::Stanza::Iq.new(:set, to)
      Nokogiri::XML::Builder.with(iq) do |xml|
        xml.answer("xmlns" => "urn:xmpp:ozone:1")
      end
      iq
    end

    def answer
      p 'inside of answer'
      p "answer to #{Connfu.context.from.to_s}"
      Connfu.connection.write answer_iq(Connfu.context.from.to_s)
    end

    def say_iq(to, text)
      iq = Blather::Stanza::Iq.new(:set, to)
      Nokogiri::XML::Builder.with(iq) do |xml|
        xml.say_("xmlns" => "urn:xmpp:ozone:say:1") {
          xml.speak text
        }
      end
      iq
    end

    def say(text)
      p 'inside of say'
      p Connfu.context
      p Connfu.context.from
      Connfu.connection.write say_iq(Connfu.context.from.to_s, text)
    end

  end

end