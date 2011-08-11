module Connfu
  module Dsl
    module Recording
      def recordings
        @recordings ||= []
      end

      def start_recording(options = {})
        send_start_recording(options)
      end

      def record_for(max_length, options = {})
        send_start_recording(options.merge(:max_length => max_length))
        event = wait_for(Connfu::Event::RecordingStopComplete)
        recordings << event.uri
      end

      def stop_recording
        send_command Connfu::Commands::Recording::Stop.new(:call_jid => call_jid, :client_jid => client_jid, :ref_id => @ref_id)
        event = wait_for(Connfu::Event::RecordingStopComplete)
        recordings << event.uri
      end
    end
  end
end