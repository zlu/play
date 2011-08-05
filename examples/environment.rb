require 'rubygems'
require 'bundler/setup'
require 'connfu'

CONNFU_CONFIG = {
  'default' => {
    :connfu_uri => 'jid://usera:1@127.0.0.1',
    :redis_url => 'redis://localhost:6379'
  }
}
CONNFU_CONFIG['amazon'] = CONNFU_CONFIG['default'].merge(:connfu_uri => 'jid://usera:1@46.137.85.52')
CONNFU_CONFIG['linode'] = CONNFU_CONFIG['default'].merge(:connfu_uri => 'jid://usera:1@173.255.241.49')

CONNFU_ENV = ENV['CONNFU_ENV'] || 'default'

Connfu.config.uri = CONNFU_CONFIG[CONNFU_ENV][:connfu_uri]

logfile = File.expand_path('../../log/xmpp.log', __FILE__)
Connfu.io_log = Connfu::Logging::IOLogger.new(logfile)

def exit_with_usage_message
  puts "Specify the destination SIP address by setting the DIAL_TO environment variable"
  exit 1
end

def update_status(status)
  logfile = File.expand_path('../../log/example_status.log', __FILE__)
  File.open(logfile, "a") { |f| f.puts "Status change: #{status}" }
end