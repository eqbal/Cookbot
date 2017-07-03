require "twitter"
require "dotenv/load"
require "logging"
require "json"
require "http"
require "shorturl"

require_relative "./twitter_bot/helpers"
require_relative "../services/find_recipes"
require_relative "../models/recipe"
require_relative "./twitter_bot/listener"
require_relative "./twitter_bot/responder"

