module Connfu
  module Component
    def say(text)
      l.debug 'sending say iq'
      Connfu.adaptor.send_command Connfu::Commands::Say.new(:text => text, :to => server_address, :from => client_address)
      wait
    end
  end
end