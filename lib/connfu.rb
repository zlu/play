%w[
  rubygems
  blather/client/client
  blather/client/dsl
  awesome_print

  connfu/commands
  connfu/offer
  connfu/server
  connfu/credentials
  connfu/utils
].each {|file| require file }

module Connfu

  def self.setup(host, password)
    connection = Blather::Client.new.setup(host, password)
    connection.register_handler(:ready, lambda{ p 'Established connection to Connfu Server'})
    connection.register_handler(:iq) do |abc|
      p abc
    end
    EM.run{connection.run}
    connection
  end

end