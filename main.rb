#! /usr/bin/env ruby
# frozen_string_literal: true

require 'nokogiri'
require 'json'
require 'uri'
require 'net/http'
require 'color_converter'
require 'open-uri'

colors = %w[#ebedf0 #9be9a8 #40c463 #30a14e #216e39s]
panels = %w[7678 24134 14755 43428 12412 55637 36730 28113 25017]

def fetchVar(name)
  throw("Set environment variable '#{name}'.") if ENV[name].nil?
  ENV[name]
end

def fetchGitHubActivity(length)
  html = Nokogiri::HTML.parse(URI.open("https://github.com/#{fetchVar('GITHUB_USER')}"))
  days = []
  boxes = html.css('rect.ContributionCalendar-day')
  boxes.each { |item| days.append(Integer(item['data-level'])) unless item['data-date'].nil? }
  days.last(length)
end

def sendPanelColors(data)
  effect = JSON.parse(File.read('effect.json'))
  effect['write']['animData'] = data
  url = URI("http://#{fetchVar('NANOLEAF_HOST')}/api/v1/#{fetchVar('NANOLEAF_TOKEN')}/effects")
  http = Net::HTTP.new(url.host, url.port)
  request = Net::HTTP::Put.new(url)
  request.body = JSON.generate(effect)
  response = http.start { |req| req.request(request) }
  throw("Unable to change colors (#{response.code} #{response.body})") unless response.code.eql?('204')
end

days = fetchGitHubActivity(panels.length)
puts "Activity levels: #{days.join(' ')}"
data = []
panels.each_with_index do |id, i|
  color = colors[days[i]]
  data << "#{id} 1 #{ColorConverter.rgb(color).join(' ')} 0 5"
end

sendPanelColors("#{panels.length} #{data.join(' ')}")
