%w[
  rubygems
  blather/client/client
  awesome_print

  connfu/commands
  connfu/offer
  connfu/server
  connfu/credentials
  connfu/utils
].each {|file| require file }

module Connfu
  def self.setup(host, password)
    connection = Blather::Client.new
    connection.setup(host, password)
    connection
  end
end