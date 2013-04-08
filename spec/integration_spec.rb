require_relative 'spec_helper'

describe "Sundial" do
  valid_numbers.each do |number|
    context "if you give a valid number #{number[:string]}" do

      it "will give the timezone(s) #{number[:timezone].join(",")}" do
        get URI.encode("/#{number[:string]}")
        last_response.should be_ok
        number[:timezone].each do |tz|
          last_response.should match Regexp.new(tz)
        end
      end

    end 
  end

  invalid_numbers.each do |number|
    context "if you give an invalid number #{number[:string]}" do

      it "will return an error" do
        expect { 
          get URI.encode("/#{number[:string]}") 
        }.to raise_error(ConverterException)
      end

    end
  end
end

