#! /usr/bin/env ruby
# frozen_string_literal: true

require 'nokogiri'
require 'json'
require 'uri'
require 'net/http'
require 'color_converter'
require 'open-uri'
require 'graphql/client'
require 'graphql/client/http'
require 'date'

def fetch_var(name)
  throw("Set environment variable '#{name}'.") if ENV[name].nil?
  ENV[name]
end

module Github
  HTTP = GraphQL::Client::HTTP.new('https://api.github.com/graphql') do
    def headers(_context)
      { 'Authorization' => "Bearer #{fetch_var('GITHUB_TOKEN')}" }
    end
  end
  Schema = GraphQL::Client.load_schema(HTTP)
  Client = GraphQL::Client.new(schema: Schema, execute: HTTP)
  UserProfileQuery = Client.parse <<~'GRAPHQL'
      query($from: DateTime, $to: DateTime) {
      viewer {
        contributionsCollection(from: $from, to: $to) {
          contributionCalendar {
            weeks {
              contributionDays {
                color
                date
              }
            }
          }
        }
      }
    }
  GRAPHQL

  def self.query(from, to)
    response = Client.query(UserProfileQuery, variables: { from: from, to: to })
    raise response.errors[:data].join(', ') if response.errors.any?

    response.data.viewer.contributions_collection.contribution_calendar.to_h
  end
end

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
  github = Github.query((Date.now - panels.length), DateTime.now.iso8601)
  data = []
  days = {}
  github['weeks'].each { |i| i['contributionDays'].each { |day| days[day['date']] = day['color'] } }
  days = days.last(panels.length)
  panels.each.with_index { |panel, day| data << "#{panel} 1 #{ColorConverter.rgb(days.values[day]).join(' ')} 0 5" }
  puts data
  Nanoleaf.send("#{panels.length} #{data.join(' ')}")
end
