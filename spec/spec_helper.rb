# encoding: UTF-8

require 'rspec'
require 'rack/test'
require 'csv'

require_relative '../lib/sundial'

# setup test environment
set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false

def app 
  Sinatra::Application
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
end

def urlize(input)
  "/#{sanitize(input)}"
end

def valid_numbers
  numbers = []
  CSV.foreach(File.dirname(__FILE__) + '/../data/area_codes.csv') do |line|
    number = {}
    number[:string] = "(#{line.first}) 123 4567"
    number[:timezone] = line.last.split("+")
    numbers << number
  end
  shortnames = {}
  CSV.foreach(File.dirname(__FILE__) + '/../data/short_names.csv') do |line|
    shortnames[line.first] = line[1..-1]
  end
  numbers.each do |number|
    number[:timezone] = number[:timezone].map { |t| shortnames[t] }.flatten.uniq
  end
  out = []
  numbers.each do |number|
    new = number.dup
    out << new
    new[:string] =  "001 " + number[:string]
    out << new
    new = number.dup
    new[:string] =  "+1 " + number[:string]
    out << new
  end
  out
end

def invalid_numbers
  invalid_area_codes = [
    "2995671234", "+1 2995671234", "+001 2995671234", "+1 501234567", 
  ]
  invalid_numbers = [
    "1", "12324", "+11 1234567123", "+2 2074567123", 
    "501234567", "+001 50123456"
  ]
  numbers = []

  invalid_area_codes.each do |n|
    number = {}
    number[:string] = n
    number[:error] = "has an unknown area code"
    numbers << number
  end
  invalid_numbers.each do |n|
    number = {}
    number[:string] = n
    number[:error] = "is not a recognised US telephone number."
    numbers << number
  end
  numbers << { 
    :string => "123/456-7890", 
    :error => "has an unknown area code"
  }
  numbers << { 
    :string => "http://www.google.com/",
    :error => "is not a recognised telephone number"
  }
  numbers
end

def intl_valid_numbers
  numbers = [
    { :string => "+385 (915) 125 486",
      :timezone => ["+01", "+02"] },
    { :string => "+49 (0)228 29970299",
      :timezone => ["+01", "+02"] },
    { :string => "[7] (343) 253-1433",
      :timezone => ["+03", "+04", "+06", "+07", "+08", "+09", "+10", "+11", "+12" ]},
    { :string => "+44 (0)1481 723552",
      :timezone => ["+00", "+01"] },
  ]
end

def past_failures
  numbers = [
    { :string => "/ [ 209 .* > 123 < 345/>1" },
    { :string => "209/456-7890" },
    { :string => "Mobile /: (208] 342.2323" },
  ]
end
