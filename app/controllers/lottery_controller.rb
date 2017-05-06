require 'net/http'
require 'csv'

class LotteryController < ApplicationController
  def index
    uri = URI('https://data.ny.gov/resource/h6w8-42p9.json')
    response = Net::HTTP.get(uri)
    results = JSON.parse(response)

    winning_numbers = Hash.new(0)
    results.select{ |res| res['draw_date'].to_date >= Date.new(2013,10,19) }.each do |res|
      nums = res['winning_numbers'].split(' ').collect{ |n| n.to_i }
      nums.each do |n|
        winning_numbers[n] += 1
      end
    end

    winning_numbers = winning_numbers.sort.to_h

    column_names = ['number', 'count']
    csv_str = CSV.generate do |csv|
      csv << column_names
      winning_numbers.each do |number_count|
        csv << number_count
      end
    end

    @data_json = winning_numbers.collect{ |n| {'number' => n.first, 'count' => n.second} }.to_json
  end
end
