# encoding: utf-8

module Amazon

  module WebsiteSetting
    def init
      @name = "Amazon"
      @description = "Amazon.com"
      @website_url = 'http://www.amazon.com'
      @sources = %w{
        http://www.amazon.com/sitemap_vendor_videos_us.xml
      }
    end
  end

  module PageSetting
    attr_accessor :name, :description, :pictures, :price

    def parse
      @name = @html_doc.at_css('#aiv-content-title').text.strip rescue nil
      @description = @html_doc.at_css('.dv-simple-synopsis').text.strip rescue nil
      @pictures = @html_doc.at_css('.dp-img-bracket img')[:src] rescue nil
      @price = @html_doc.at_css('.dv-button-inner').text.strip.scan(/[0-9]+/).join('.').to_f rescue nil
    end
  end

end
