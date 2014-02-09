# encoding: utf-8

Dir["./app/api/**/*.rb"].each { |f| require f }

class Server < Grape::API
  version 'v1', using: :path, vendor: 'sidecrawl'
  format :json
  default_format :json

  helpers HelperBase

  rescue_from :all do |e|
    Server.logger.fatal "[FATAL] rescued from API #{e.class.name}: #{e.to_s} in #{e.backtrace.first}"
    rack_response({ message: "rescued from API error: #{e.class.name}", exception: e.to_s, detail: e.backtrace.to_s })
  end

  resource 'servicehealth' do
    get "/" do
      @servicehealth = ServiceHealth.new
      render_custom 'servicehealth', @servicehealth, 200
    end
  end

  mount Api::V1::Pages
  mount Api::V1::Websites
end
