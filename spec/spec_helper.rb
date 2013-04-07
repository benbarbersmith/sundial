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

def valid_numbers
  numbers = []
  CSV.foreach(File.dirname(__FILE__) + '/../data/areacodes.csv') do |line|
    number = {}
    number[:string] = "(#{line.first}) 123 4567"
    number[:timezone] = line.last.split("+")
    numbers << number
  end
  shortnames = {}
  CSV.foreach(File.dirname(__FILE__) + '/../data/shortnames.csv') do |line|
    shortnames[line.first] = line.last
  end
  numbers.each do |number|
    number[:timezone] = number[:timezone].map { |t| shortnames[t] }
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
  numbers = []
  ["2995671234", "+1 2995671234", "+001 2995671234", "+1 501234567", ].each do |n|
    number = {}
    number[:string] = n
    number[:error] = "has an unknown area code"
    numbers << number
  end
  ["1", "12324", "+11 1234567123", "+2 2074567123", "501234567", "+001 50123456"].each do |n|
    number = {}
    number[:string] = n
    number[:error] = "is not a recognised US telephone number."
    numbers << number
  end
  numbers
end
