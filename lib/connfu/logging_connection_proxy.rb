module Connfu
  class LoggingConnectionProxy
    def initialize(connection)
      @connection = connection
    end

    def proxied_connection
      @connection
    end

    def send_command(command)
      iq = command.to_iq
      l.debug iq
      @connection.write iq
    end

    def method_missing(method, *args, &block)
      @connection.send(method, *args, &block)
    end
  end
end