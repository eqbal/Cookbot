module Services
  class FindRecipes
    include TwitterBot::Helpers

    attr_reader :response

    def initialize(query)
      @client = HTTP.auth(bearer_token).headers(headers)
      @query = normalize(query)
    end

    def run
      find_query
      parse_response
      retry_when_suggestion
    end

    def has_results?
      response["extra"]["total_count"] > 0
    end

    private

      attr_reader :client, :query

      def find_query(search = query)
        @response = client.get(
          ENV["cookpad_staging_recipes_url"],
          params: { query: search }
        )
      end

      def parse_response
        @response = JSON.parse(response)
      end

      def retry_when_suggestion
        return self if has_results?

        if no_suggestions?
          puts "no suggestion"
          logger.info "Couldn't find results for #{query} suggestion"
          return self
        else
          logger.info "Retry with #{suggestion} suggestion"
          return FindRecipes.new(suggestion).run
        end
      end

      def headers
        {
          "accept": "application/json",
          "X-Cookpad-Provider-Id": "9",
          "X-Cookpad-Country-Code": "LB"
        }
      end

      def bearer_token
        "Bearer #{ENV['cookpad_staging_token']}"
      end

      def no_suggestions?
        suggestions.empty?
      end

      def suggestions
        response["extra"]["spelling_suggestions"]
      end

      def suggestion
        suggestions.first
      end
  end
end
