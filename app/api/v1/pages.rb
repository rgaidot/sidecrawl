# encoding: utf-8

module Api
  module V1
    class Pages < Grape::API
      version 'v1', using: :path, vendor: 'sidecrawl'
      URL_REGEXP   = /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix

      resource :pages do
        get '/' do
          website_name = params[:website_name]
          if website_name
            Server.logger.info "[#{website_name}]: all pages"
            @pages = []
            @website = Website.new({:name => website_name})
            @website.sitemap(params[:i])
            @website.urls.each_with_index do |url, i|
              @pages.push Page.new({:link => url, :website_name => website_name})
            end
            render_custom "pages", "api/v1/pages/index", @pages, 200
          else
            error!({ "error" => "unexpected error", "detail" => "missing website_name" }, 500)
          end
        end

        get '/show' do
          url =  params[:url]
          website_name = params[:website_name]
          if url && url =~ URL_REGEXP || website_name == nil
            Server.logger.info "[#{website_name}]: #{url}"
            @page = Page.new({:link => url, :website_name => website_name})
            render_custom "page", "api/v1/pages/show", @page, 200
          else
            error!({ "error" => "unexpected error", "detail" => "missing website_name or url" }, 500)
          end
        end
      end

    end
  end
end
