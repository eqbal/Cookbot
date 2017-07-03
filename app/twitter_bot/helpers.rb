require 'open-uri'

module TwitterBot
  module Helpers

    def twitter_keys
      @keys ||= {
        consumer_key: ENV["consumer_key"],
        consumer_secret: ENV["consumer_secret"],
        access_token: ENV["access_token"],
        access_token_secret: ENV["access_token_secret"]
      }
    end

    def open_from_url(image_url)
      image_file = open(image_url)
      return image_file unless image_file.is_a?(StringIO)

      file_name = File.basename(image_url)

      temp_file = Tempfile.new(file_name)
      temp_file.binmode
      temp_file.write(image_file.read)
      temp_file.close

      open(temp_file.path)
    end

    def normalize(tweet)
      tweet = tweet.gsub(/-/, '')
      tweet = tweet.gsub(/(@\w+)|(#\w+)/, '')
      tweet = tweet.gsub(/[^\u{0}-\u{FFFF}]/, '?')
      tweet = tweet.gsub(/\.?\s*@[0-9A-Za-z_]+/, '')
      tweet = tweet.gsub(/(RT|QT)\s*@?[0-9A-Za-z_]+.*$/, '')
      tweet = tweet.gsub(/http:\/\/\S+/, '')
      tweet = tweet.gsub(/#[0-9A-Za-z_]+/, '')
      tweet.strip
    end

    def logger
      @_logger ||=  Logging.logger(STDOUT)
    end
  end
end
