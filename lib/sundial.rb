# encoding: utf-8

require 'sinatra'
require_relative 'converter'

disable :show_exceptions
disable :raise_errors

converter = Converter.new

get '/' do
  redirect 'https://github.com/benjaminasmith/sundial'
end

get '/:input' do |input|
  results = converter.convert(input)
  # Return a readable output string.
  results.map do |r|
    "#{r[:time]} #{r[:timezone]} (GMT #{'+' if r[:offset] > 0}#{r[:offset]})"
  end.join(" or ")
end

error do
  'An error occured: ' + request.env['sinatra.error'].message
end
