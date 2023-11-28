#! /usr/bin/env ruby
# frozen_string_literal: true

require 'color_converter'
require 'date'
require 'json'
require 'net/http'
require 'oga'
require 'open-uri'
require 'uri'
require 'dotenv/load'

def colors
  colors_json = JSON.parse(File.read('colors.json'))
  colors_json[Date.today.strftime('%m/%d')] || colors_json['default']
end

def fetch_layout
  panels = Nanoleaf.panels

  # Create a 2D array to represent the layout
  layout = []

  # Fill in the layout based on the X and Y coordinates
  panels['positionData'].each do |panel|
    row = panel['y'] / panels['sideLength']
    col = panel['x'] / panels['sideLength']
    # Initialize the inner array if it's nil
    layout[row] ||= []
    layout[row][col] = panel['panelId']
  end

  output = layout.map { |row| row&.reverse&.join(' ') }
  output.join(' ')
end

def fetch_var(name)
  ENV[name].nil? ? throw("Set environment variable '#{name}'.") : ENV[name]
end

def fetch_github_activity(length)
  days = Oga.parse_html(URI.open("https://github.com/#{fetch_var('GITHUB_USER')}")).css('td.ContributionCalendar-day')
  days.map do |item|
    next if item['data-date'].nil? || Date.parse(item['data-date']) > Date.today

    days << { date: Date.parse(item['data-date']), level: Integer(item['data-level']) }
  end

  # Sort the days array by the 'date' key in ascending order.
  sorted_days = days.sort_by { |day| day[:date] }
  # Return the last 'length' data-level values from the sorted array.
  sorted_days.last(length).map { |day| day[:level] }
end

# Nanoleaf API module
module Nanoleaf
  def self.api_url
    "http://#{fetch_var('NANOLEAF_HOST')}/api/v1/#{fetch_var('NANOLEAF_TOKEN')}"
  end

  def self.effect
    JSON.parse(File.read('effect.json'))
  end

  def self.send(data)
    url = URI("#{api_url}/effects")
    request = Net::HTTP::Put.new(url)
    request.body = JSON.generate(effect['write']['animData'] = data)
    response = Net::HTTP.new(url.host, url.port).start { |http| http.request(request) }
    throw("Unable to change colors (#{response.code})") unless response.code.eql?('204')
  end

  def self.on?
    response = Net::HTTP.get_response(URI("#{api_url}/state"))
    throw("Unable to change colors (#{response.code})") unless response.code.eql?('200')
    JSON.parse(response.body)['on']['value']
  end

  def self.panels
    response = Net::HTTP.get_response(URI("#{api_url}/panelLayout/layout"))
    throw("Unable to fetch panels (#{response.code})") unless response.code.eql?('200')
    JSON.parse(response.body)
  end
end

if Nanoleaf.on?
  panels = (ENV['PANELS'] || fetch_layout).split(' ')
  github = fetch_github_activity(panels.length)
  data = []
  panels.each.with_index { |panel, day| data << "#{panel} 1 #{ColorConverter.rgb(colors[github[day]]).join(' ')} 0 5" }
  Nanoleaf.send("#{panels.length} #{data.join(' ')}")
end

