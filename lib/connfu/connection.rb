require 'connfu'

class Connfu::Connection
  include Connfu::Logging

  attr_accessor :blather_client

  def initialize(config)
    @blather_client = establish_connection(config)
  end

  def send_command(command)
    iq = command.to_iq
    logger.debug iq
    blather_client.write iq
    Connfu.io_log.sent iq if Connfu.io_log
    command.id
  end

  def wait_because_of_tropo_bug_133
    sleep 1 # This is necessary, see https://github.com/tropo/tropo2/issues/133
  end

  def method_missing(method, *args, &block)
    blather_client.send(method, *args, &block)
  end

  def establish_connection(config)
    Blather::Client.new.setup("#{config.user}@#{config.host}", config.password).tap do |connection|
      [:iq, :presence].each do |stanza_type|
        connection.register_handler(stanza_type) do |stanza|
          logger.debug "Receiving #{stanza_type} from server"
          logger.debug stanza.inspect
          Connfu.handle_stanza(stanza)
        end
      end

      connection.register_handler(:ready) do |stanza|
        logger.debug "Established @connection to Connfu Server with JID: #{config.uri}"
        logger.debug "Queue implementation: #{Connfu::Queue.implementation.inspect}"
        throw :pass
      end
    end
  end
end