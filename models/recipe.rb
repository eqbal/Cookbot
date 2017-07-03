module Models
  class Recipe
    attr_reader :title, :image_url, :description, :story, :url

    def initialize(attributes)
      @title = attributes["title"]
      @image_url = "#{attributes['image']['url']}/mq50/photo.jpg"
      @description = attributes["description"]
      @story = attributes["story"]
      @url = attributes["href"]
    end

    def title_with_short_url
      "#{title} #{short_url}"
    end

    private

      def short_url
        ShortURL.shorten(url)
      end

  end
end
