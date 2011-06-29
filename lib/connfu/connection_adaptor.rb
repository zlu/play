module Connfu
  class ConnectionAdaptor
    def initialize(connection)
      @connection = connection
    end

    def send_command(command)
      iq = Connfu::Ozone.iq_from_command(command)
      l.debug iq
      @connection.write iq
    end
  end
end