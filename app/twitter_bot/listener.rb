module TwitterBot
  class Listener
    include Helpers

    def initialize
      @stream = Twitter::Streaming::Client.new(twitter_keys)
    end

    def call
      stream.filter(track: channel_name) do |object|
        next unless valid_object?(object)
        TwitterBot::Responder.new(object).call
      end
    end

    private
      attr_reader :stream

      def valid_object?(object)
        (object.is_a? Twitter::Tweet)
      end

      def channel_name
        "##{ENV['cookpad_bot_name']}"
      end
  end
end
