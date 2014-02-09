# encoding: utf-8

module Api
  module V1
    class Websites < Grape::API
      version 'v1', using: :path, vendor: 'sidecrawl'

      resource :websites do
        get '/' do
          name =  params[:name]
          if name
            Server.logger.info "[#{name}]: info"
            @website = Website.new({:name => name})
            render_custom "website", "api/v1/websites/show", @website, 200
          else
            error!({ "error" => "unexpected error", "detail" => "missing name" }, 500)
          end

        end

        get '/sitemap' do
          name =  params[:name]
          if name
            Server.logger.info "[#{name}]: sitemap"
            @website = Website.new({:name => name})
            @website.sitemap(params[:source])
            render_custom "website", "api/v1/websites/sitemap", @website, 200
          else
            error!({ "error" => "unexpected error", "detail" => "missing name" }, 500)
          end
        end
      end

    end
  end
end

