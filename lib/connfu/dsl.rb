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
        send_command Connfu::Commands::Say.new(:text => text, :to => server_address, :from => client_address)
        wait
      end

      def answer
        send_command Connfu::Commands::Answer.new(:to => server_address, :from => client_address)
      end

      def reject
        send_command Connfu::Commands::Reject.new(:to => server_address, :from => client_address)
      end

      def hangup
        send_command Connfu::Commands::Hangup.new(:to => server_address, :from => client_address)
      end

      def redirect(redirect_to)
        send_command Connfu::Commands::Redirect.new(:redirect_to => redirect_to, :to => server_address, :from => client_address)
      end

      def transfer(*transfer_to)
        options = transfer_to.last.is_a?(Hash) ? transfer_to.pop : {}
        if options.delete(:mode) == :round_robin
          result = nil
          transfer_to.each do |sip_address|
            result = transfer sip_address, options
            break if result.answered?
          end
          return result
        else
          command_options = {:transfer_to => transfer_to, :to => server_address, :from => client_address}
          command_options[:timeout] = options[:timeout] * 1000 if options[:timeout]
          send_command Connfu::Commands::Transfer.new(command_options)
          wait
        end
      end

      def handle_event(event)
        case event
          when Connfu::Event::Offer
            start
          when Connfu::Event::SayComplete
            continue
          when Connfu::Event::TransferSuccess
            continue(TransferState.answered)
          when Connfu::Event::TransferTimeout
            continue(TransferState.timeout)
          when Connfu::Event::TransferRejected
            continue(TransferState.rejected)
          when Connfu::Event::Result
            continue
          when Connfu::Event::Error
            continue(:error)
        end
      end

      private

      def send_command(command)
        Connfu.adaptor.send_command command
        l.debug "Sent command: #{command}"
        result = wait
        l.debug "Result from command #{result}"
        raise if result == :error
      end
    end

    def initialize(params)
      @server_address = params[:from]
      @client_address = params[:to]
    end

  end
end