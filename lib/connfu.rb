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
    connection.register_handler(:iq, 'iq/offer', :ns => 'urn:xmpp:ozone:1') do
      p 'Start to handle incoming offer'
    end
    connection
  end

end