#!/usr/bin/env ruby
# encoding: utf-8
require 'open-uri'
require 'json'

class AppController < Sinatra::Base
  RSS_URL = {
    "beijing" => "http://www.stateair.net/web/rss/1/1.xml",
    "chengdu" => "http://www.stateair.net/web/rss/1/2.xml",
    "guangzhou" => "http://www.stateair.net/web/rss/1/3.xml",
    "shanghai" => "http://www.stateair.net/web/rss/1/4.xml",
    "shenyang" => "http://www.stateair.net/web/rss/1/5.xml"
  }

  get '/' do
    ''
  end

  get '/aqi/:city.json' do
    @info = {:status => -1, :data => [], :msg => ""}
    @city = params[:city]

    if RSS_URL.keys.include?(@city)
      begin
        open(RSS_URL[@city]) do |xml|
          feed = Nokogiri::XML(xml)
          feed.xpath("//item").each do |item|
            title = item.xpath("title").text
            conc = item.xpath("Conc").text
            aqi = item.xpath("AQI").text
            desc = item.xpath("Desc").text.gsub(" (at 24-hour exposure at this level)", '')
            timestamp = item.xpath("ReadingDateTime").text
            timestamp = Time.parse(timestamp).to_i

            next if aqi.to_i < 0

            @info[:data] << {
              :city=> @city,
              :timestamp => timestamp,
              :title => title,
              :conc => conc,
              :aqi => aqi,
              :desc => desc
            }
          end
        end
        @info[:status] = 0
        @info[:msg] = "Success!"
      rescue
        @info[:status] = 1
        @info[:msg] = "Server Error!"
      end

    else
      @info[:status] = 2
      @info[:msg] = "City Not Found!"

    end

    content_type 'application/json'
    @info.to_json
  end
end
