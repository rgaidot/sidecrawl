# SideCrawl

SideCrawl is a simple web spider extensible (via Module) written with Goliath (EventMachine/Ruby). It gives you the full power of jQuery like (via nokogiri) on the server to parse a big number of pages asynchronously.

## Prerequisites

You need to have [rvm](http://rvm.io/).

## Setup Instructions

```bash
$ rvm install 2.0
$ bundle install
```


## Getting Started

### Create module

To define rules to retrieve the page elements - you need to create a module. Sidecrawl use sitemap for crawling but you can override easily. See below example

```ruby
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
```

### Output

You can change the output format page simply by changing the view (written in [RABL](https://github.com/nesquena/rabl)).

```rabl
object @page

attributes :name, :description, :pictures, :price
```

### Environment variables

You can specify environment variables in the file .env

| Variables           | Descriptions        |
| --------------------|---------------------|
| PORT                | Listening ports     |
| SERVER_URL          | URL server          |
| RECEIVER_URL        | URL server receiver |
| TIMEOUT             | Timeout             |
| CONCURRENCY_SOURCE  | Concurrency source  |
| CONCURRENCY_PAGE    | Concurrency page    |

### Run sidecrawl

Sidecrawl uses [foreman](http://ddollar.github.io/foreman/). You can specified the number of each process type to run (e.g. web=8). Check out the [foreman documentation](http://ddollar.github.io/foreman/) 

```bash
$ foreman start web=4
```

### Sidecrawl Guide

Sidecrawl has an API to show the results.

* Website configurations
http://localhost:5000/v1/websites/?name=amazon

* Website sitemap - if you have declared many sitemap, add `i` on params
http://localhost:5000/v1/websites/sitemap?name=amazon&i=3

* Retrieve page elements by url
http://localhost:5000/v1/pages/show?url=http://www.amazon.com/Matrix-Keanu-Reeves/dp/B000HAB4KS/&website_name=amazon


### Crawling a website

You can run a crawl task via a rake. See below example

```bash
$ rake crawl['amazon']
```


## Performance: MRI, JRuby, Rubinius

SideCrawl isn't tied to a single Ruby runtime - it is able to run on MRI Ruby, JRuby and Rubinius today. Depending on which platform you are working with, you will see different performance characteristics.
```
