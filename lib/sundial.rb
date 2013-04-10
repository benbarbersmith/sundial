# encoding: utf-8

require 'sinatra'
require_relative 'converter'

disable :show_exceptions
disable :raise_errors

converter = Converter.new

get '/' do
  # Numbers will be provided via a ?convert= parameter.
  if params[:convert].nil?
    # If no number has been provided, show a clear index page.
    erb :index, :locals => {
      :input => nil
    }
  else
    # If a number has been provided, redirect to a friendly URL.
    redirect URI::encode("/" + params[:convert]).gsub(/(\[|\])/,'') 
  end
end

get '/:input' do |input|
  # Get timezone results for the input string.
  results = converter.convert(input)
  # Build a readable output string.
  time = results.map do |r|
    r[:time] + " UTC" + r[:offset]
  end.uniq
  timezone = results.map do |r|
    r[:timezone]
  end
  # If there are many results, just simplify things.
  if time.size > 2 or timezone.size > 2
    time = ["Sometime between #{time.first} and #{time.last}"]
    timezone = ["Somewhere between #{timezone.first} and #{timezone.last}"]
  end
  # Render template to present outputs neatly.
  erb :result, :locals => {
    :input => input, 
    :time => time.join(" or "),
    :timezone => timezone.join(" or "),
  }
end

error do
  # If in doubt, render an error message.
  erb :error, :locals => {
    :input => nil,
    :error => 'An error occured: ' + request.env['sinatra.error'].message,
  }
end
