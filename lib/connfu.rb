%w[
  rubygems
  blather/client/client
  blather/client/dsl
  awesome_print

  connfu/commands
  connfu/offer
  connfu/credentials
  connfu/utils
].each {|file| require file }

module Connfu

  def self.setup(host, password)
    connection = Blather::Client.new.setup(host, password)
    connection.register_handler(:ready, lambda{ p 'Established connection to Connfu Server'})
    connection.register_handler(:iq) do |abc|
      p abc
      abc
    end
    connection
  end

  def self.start(connection)
    EM.run{connection.run}
  end

  def self.on(event)
    p event
    yield self
  end

end