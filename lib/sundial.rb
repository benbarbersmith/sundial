# encoding: utf-8

require 'sinatra'
require_relative 'converter'

converter = Converter.new

get '/' do
  redirect 'https://github.com/benjaminasmith/sundial'
end

get '/:input' do |input|
  converter.convert(input)
end
