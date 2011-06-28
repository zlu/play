module Connfu
  module Dsl
    def self.included(base)
      base.send(:include, Connfu::Continuation)
      base.send(:include, Connfu::Dsl::InstanceMethods)
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

    module InstanceMethods
      def say(text)
        Connfu.adaptor.send_command Connfu::Commands::Say.new(:text => text, :to => server_address, :from => client_address)
        wait
      end

      def answer
        Connfu.adaptor.send_command Connfu::Commands::Answer.new(:to => server_address, :from => client_address)
      end

      def reject
        Connfu.adaptor.send_command Connfu::Commands::Reject.new(:to => server_address, :from => client_address)
      end

      def hangup
        Connfu.adaptor.send_command Connfu::Commands::Hangup.new(:to => server_address, :from => client_address)
      end

      def redirect(redirect_to)
        Connfu.adaptor.send_command Connfu::Commands::Redirect.new(:redirect_to => redirect_to, :to => server_address, :from => client_address)
      end

      def transfer(transfer_to)
        Connfu.adaptor.send_command Connfu::Commands::Transfer.new(:transfer_to => transfer_to, :to => server_address, :from => client_address)
      end
    end

    def initialize(params)
      @server_address = params[:from]
      @client_address = params[:to]
    end

  end
end