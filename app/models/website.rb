# encoding: utf-8


class Website
  attr_accessor :name, :description, :website_url, :urls, :sources

  def initialize(options)
    @urls = []
    options.each_pair do |key, val|
      instance_variable_set('@' + key.to_s, val)
    end
    add_specific_methods
  end

  def sitemap(i)
    req = EM::HttpRequest.new(URI.parse(@sources[i.to_i]).normalize).get :head => {'Accept' => '*/*', 'User-Agent' => 'Mozilla/5.0 (compatible; Google/2.1)' }, :redirects => 5
    req.callback do
      if req.response_header['CONTENT_TYPE'].include? 'gzip'
        @xml_doc = Nokogiri::XML(Zlib::GzipReader.new(StringIO.new(req.response)).read)
      else
        @xml_doc = Nokogiri::XML(req.response)
      end
      @urls.concat @xml_doc.css("loc").map(&:text).map(&:strip).uniq
    end
  end

  private
    def camelized_name
      self.name.camelize
    end

    def add_specific_methods
      self.extend(eval(camelized_name)::WebsiteSetting).init
    end

end

