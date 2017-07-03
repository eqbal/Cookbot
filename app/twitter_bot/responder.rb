module TwitterBot
  class Responder
    include Helpers

    def initialize(tweet)
      @rest = Twitter::REST::Client.new(twitter_keys)
      @tweet = tweet
    end

    def call
      log_request_infos
      find_recipes
      chose_and_parse_random_recipe
      reply_to_tweet
    end

    private

      attr_reader :rest, :tweet, :recipes, :recipe, :chosen_recipe

      def find_recipes(query = tweet.text)
        @recipes = ::Services::FindRecipes.new(query).run

        if recipes.has_results?
          logger.info "#{recipes.response['extra']['total_count']} receipes has been found"
        else
          logger.error "Could't find results or suggestions for #{query}"
          tweet_no_results
        end
      rescue Exception => e
        logger.error e.message
      end

      def chose_and_parse_random_recipe
        return unless recipes.has_results?

        @chosen_recipe = recipes.response["result"].sample
        logger.info "#{chosen_recipe['title']} has been chosen"
        @recipe = ::Models::Recipe.new(chosen_recipe)
      end

      def reply_to_tweet
        return unless recipes.has_results?
        return unless tweet.in_reply_to_status_id.is_a? Twitter::NullObject

        rest.update_with_media(
          "@#{sender_name} #{recipe.title_with_short_url}",
          open_from_url(recipe.image_url),
          in_reply_to_status_id: tweet.id
        )
        logger.info "#{chosen_recipe['title']} posted to #{sender_name}"
      end

      def tweet_no_results
        rest.update(
          "@#{sender_name} Couldn't find results for #{normalized_tweet}",
          in_reply_to_status_id: tweet.id
        )
      end

      def log_request_infos
        logger.info "Received: #{tweet.text} - written by #{sender_name}"
      end

      def sender_name
        tweet.user.screen_name
      end

      def normalized_tweet
        normalize(tweet.text)
      end
  end
end
