#! /usr/bin/env ruby
# frozen_string_literal: true

require 'color_converter'
require 'date'
require 'json'
require 'net/http'
require 'oga'
require 'open-uri'
require 'uri'

def colors
  case Date.today.strftime('%m%d')
  when '0214'
    %w[#FFEBEB #FF9898 #FF6363 #D41111 #8F0000]
  when '1031'
    %w[#EBEDF0 #FDDF68 #FA7A18 #BD561D #631C03]
  when '1224'
    %w[#FFEBEB #D41111 #D10000 #990000 #6F0000]
  when '1225'
    %w[#FFEBEB #D41111 #D10000 #990000 #6F0000]
  else
    %w[#EBEDF0 #9BE9A8 #40C463 #30A14e #216E39]
  end
end

def fetch_var(name)
  ENV[name].nil? ? throw("Set environment variable '#{name}'.") : ENV[name]
end

def fetch_github_activity(length)
  html = Oga.parse_html(URI.open("https://github.com/#{fetch_var('GITHUB_USER')}"))
  days = []
  boxes = html.css('td.ContributionCalendar-day')
  boxes.each do |item|
    days << Integer(item['data-level']) unless item['data-date'].nil? || Date.parse(item['data-date']) > Date.today
  end
  days.last(length)
end

# Nanoleaf Canvas handling
module Nanoleaf
  # rubocop:disable Metrics/AbcSize
  def self.send(data)
    effect = JSON.parse(File.read('effect.json'))
    effect['write']['animData'] = data
    url = URI("http://#{fetch_var('NANOLEAF_HOST')}/api/v1/#{fetch_var('NANOLEAF_TOKEN')}/effects")
    request = Net::HTTP::Put.new(url)
    request.body = JSON.generate(effect)
    response = Net::HTTP.new(url.host, url.port).start { |http| http.request(request) }
    throw("Unable to change colors (#{response.code} #{response.body})") unless response.code.eql?('204')
  end

  def self.on?
    url = URI("http://#{fetch_var('NANOLEAF_HOST')}/api/v1/#{fetch_var('NANOLEAF_TOKEN')}/state")
    request = Net::HTTP::Get.new(url)
    response = Net::HTTP.new(url.host, url.port).start { |http| http.request(request) }
    throw("Unable to change colors (#{response.code} #{response.body})") unless response.code.eql?('200')
    body = JSON.parse(response.body)
    throw("Power state not available (#{response.code})") if body['on'].nil? || body['on']['value'].nil?
    body['on']['value']
  end

  # rubocop:enable Metrics/AbcSize
end

if Nanoleaf.on?
  panels = fetch_var('PANELS').split(' ')
  github = fetch_github_activity(panels.length)
  data = []
  panels.each.with_index { |panel, day| data << "#{panel} 1 #{ColorConverter.rgb(colors[github[day]]).join(' ')} 0 5" }
  Nanoleaf.send("#{panels.length} #{data.join(' ')}")
end
