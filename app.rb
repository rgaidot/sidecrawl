require 'rubygems'
require 'bundler/setup'
require 'goliath'
require 'fiber'
require 'rack/stream'
require 'rack/fiber_pool'
require 'grape'
require 'yaml'
require 'zlib'
require 'open-uri'
require 'nokogiri'
require 'pry'
require 'yajl'
require 'em-synchrony'
require 'em-synchrony/em-http'
require 'em-synchrony/fiber_iterator'
require 'em-http/middleware/json_response'
require 'rabl'

EM::HttpRequest.use EventMachine::Middleware::JSONResponse

Dir["./app/helpers/*.rb"].each { |f| require f }
Dir["./app/models/*.rb"].each { |f| require f }
Dir["./config/*.rb"].each { |f| require f }
Dir["./modules/*.rb"].each { |f| require f }

Rabl.configure do |config|
  config.view_paths = ['app/views']
end

require './app/server'

class Application < Goliath::API
  def response(env)
    ::Server.call(env)
  end
end
