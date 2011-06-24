module Connfu
  class ConnectionAdaptor
    def initialize(connection)
      @connection = connection
    end

    def send_command(command)
      @connection.write Connfu::Ozone.iq_from_command(command)
    end
  end
end