require 'connfu'

module Connfu
  class Client
    include Credentials

    def initialize
      Blather::Client.setup CLIENT_JID, CLIENT_PWD
    end
  end
end
