#!/usr/bin/env rake

require 'logger'
require 'em-synchrony'
require 'em-synchrony/em-http'
require 'em-synchrony/fiber_iterator'
require 'json'
require 'dotenv'

Dotenv.load

task :default => :crawl

task :build, :version do |t, args|
  version = args[:version]
  puts version ? "version is #{version}" : "no version passed"
end

task :crawl, :config_name do |t, args|
  logger = Logger.new(STDOUT)
  i = 0
  j = 0
  name = args[:config_name]
  EM.synchrony do
    logger.info "[#{name}]: get sources"
    website = EventMachine::HttpRequest.new("#{ENV['SERVER_URL']}/v1/websites", 
                                            :connect_timeout => ENV['TIMEOUT'], 
                                              :inactivity_timeout => ENV['TIMEOUT']).get :query => { :name => args[:config_name] }
    website.callback do
      if website.response_header.status == 200
        sources = JSON.parse(website.response)['website']['sources']
        source_index = 0
        EM::Synchrony::FiberIterator.new(sources, ENV['CONCURRENCY_SOURCE'].to_i).each do |s|
          logger.info "[#{name}:#{source_index}:#{s}]: get urls"
          source = EventMachine::HttpRequest.new("#{ENV['SERVER_URL']}/v1/websites/sitemap",
                                                 :connect_timeout => ENV['TIMEOUT'], 
                                                   :inactivity_timeout => ENV['TIMEOUT']).get :query => { :name => args[:config_name], :source => source_index }
          source.callback do
            if source.response_header.status == 200
              urls = JSON.parse(source.response)['website']['urls']
              EM::Synchrony::FiberIterator.new(urls, ENV['CONCURRENCY_PAGE'].to_i).each do |url|
                logger.info "[#{name}:#{source_index}:#{s}]: #{url}"
                page = EventMachine::HttpRequest.new("#{ENV['SERVER_URL']}/v1/pages/show", 
                                                    :connect_timeout => ENV['TIMEOUT'],
                                                      :inactivity_timeout => ENV['TIMEOUT']).get :query => { :website_name => args[:config_name], :url => url }
                page.callback do
                  begin
                    if page.response_header.status == 200
                      post = EventMachine::HttpRequest.new(ENV['RECEIVER_URL'], :connect_timeout => ENV['TIMEOUT'], 
                                                           :inactivity_timeout => ENV['TIMEOUT']).post :body => page.response, 
                                                             :head => {"Accept" => "application/json", "Content-type" => "application/json"}
                      post.callback do
                        if post.response_header.status == 200
                          logger.info "[#{name}:#{s}] #{url} : fetched!"
                        else
                          logger.error "[#{name}:#{s}] error with #{url} : fetch failed"
                        end
                      end
                    else
                      logger.error "[#{name}:#{source_index}:#{s}] error with #{url} : fetch failed"
                    end
                  rescue
                    logger.error "[#{name}:#{source_index}:#{s}] error with #{url} : #{$!.message}"
                  end
                end
                j += 1
                GC.start if j%100 == 0
              end
              urls = nil
            end
            source_index += 1
          end
          i += 1
          GC.start if i%100 == 0
        end
      end
    end
    EventMachine.stop
  end
end

