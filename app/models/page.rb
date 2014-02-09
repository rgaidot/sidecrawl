# encoding: utf-8

class Page
  attr_accessor :website_name, :link, :html_doc

  def initialize(options)
    options.each_pair do |key, val|
      instance_variable_set('@' + key.to_s, val)
    end
    add_specific_methods
    get_page
  end

  private
    def camelized_name
      self.website_name.camelize
    end

    def get_page
      conn = req = EM::HttpRequest.new(URI.parse(@link).normalize)
      conn.use CookiePersist
      req = conn.get :head => {'Accept' => '*/*', 'User-Agent' => 'Mozilla/5.0 (compatible; Google/2.1)' }, :redirects => 5, :keepalive => true
      req.callback {
        req.headers { |head|
          CookiePersist.cookies << head[EM::HttpClient::SET_COOKIE]
        }
        @html_doc = Nokogiri::HTML(req.response)
        parse
      }
      req.errback { |error| logger.error "Error: #{error}" }
    end

    def add_specific_methods
      self.extend(eval(camelized_name)::PageSetting)
    end

end
