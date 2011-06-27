module Connfu
  module Dsl
    def self.included(base)
      base.send(:include, Connfu::CallCommands)
      base.send(:include, Connfu::Component)
      base.send(:include, Connfu::CallHandler)
      base.extend Connfu::Dsl::ClassMethods
      base.class_eval do
        attr_reader :server_address, :client_address
      end
    end

    module ClassMethods
      def on(context, &block)
        define_method(:run, &block)
      end
    end

    def initialize(params)
      @server_address = params[:from]
      @client_address = params[:to]
    end

  end
end