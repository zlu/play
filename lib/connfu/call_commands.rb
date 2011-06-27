module Connfu
  module CallCommands
    def answer
      Connfu.adaptor.send_command Connfu::Commands::Answer.new(:to => server_address, :from => client_address)
    end

    def hangup
      Connfu.adaptor.send_command Connfu::Commands::Hangup.new(:to => server_address, :from => client_address)
      wait
    end
  end
end