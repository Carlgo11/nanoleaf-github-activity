#! /usr/bin/env ruby
# frozen_string_literal: true

require 'nokogiri'
require 'json'
require 'uri'
require 'net/http'
require 'color_converter'
require 'open-uri'

colors = %w[#ebedf0 #9be9a8 #40c463 #30a14e #216e39s]
panels = %w[14755 24134 7678 43428 12412 55637 36730 28113 25017]
data = []

def fetch_var(name)
  throw("Set environment variable '#{name}'.") if ENV[name].nil?
  ENV[name]
end

def fetch_github_activity(length)
  html = Nokogiri::HTML.parse(URI.open("https://github.com/#{fetch_var('GITHUB_USER')}"))
  days = []
  boxes = html.css('rect.ContributionCalendar-day')
  boxes.each { |item| days.append(Integer(item['data-level'])) unless item['data-date'].nil? }
  days.last(length)
end

# rubocop:disable Metrics/AbcSize
def set_colors(data)
  effect = JSON.parse(File.read('effect.json'))
  effect['write']['animData'] = data
  url = URI("http://#{fetch_var('NANOLEAF_HOST')}/api/v1/#{fetch_var('NANOLEAF_TOKEN')}/effects")
  request = Net::HTTP::Put.new(url)
  request.body = JSON.generate(effect)
  response = Net::HTTP.new(url.host, url.port).start { |http| http.request(request) }
  throw("Unable to change colors (#{response.code} #{response.body})") unless response.code.eql?('204')
end

def fetch_state
  url = URI("http://#{fetch_var('NANOLEAF_HOST')}/api/v1/#{fetch_var('NANOLEAF_TOKEN')}/state")
  request = Net::HTTP::Get.new(url)
  response = Net::HTTP.new(url.host, url.port).start { |http| http.request(request) }
  throw("Unable to change colors (#{response.code} #{response.body})") unless response.code.eql?('200')
  body = JSON.parse(response.body)
  throw("Power state not available (#{response.code})") if body['on'].nil? || body['on']['value'].nil?
  body['on']['value']
end
# rubocop:enable Metrics/AbcSize

if fetch_state
  puts days = fetch_github_activity(panels.length)
  panels.each_with_index { |id, i| data << "#{id} 1 #{ColorConverter.rgb(colors[days[i]]).join(' ')} 0 5" }
  set_colors("#{panels.length} #{data.join(' ')}")
end
