require_relative 'spec_helper'

describe "For US numbers" do
  valid_numbers.each do |number|
    context "if you give a valid number #{number[:string]}" do

      it "will give the timezone(s) #{number[:timezone].join(",")}" do
        get URI.encode("/#{number[:string]}")
        last_response.should be_ok
        number[:timezone].any? do |tz|
          last_response.body =~ Regexp.new(Regexp.escape(tz))
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

describe "For international numbers" do
  intl_valid_numbers.each do |number|
    context "if you give a valid number #{number[:string]}" do

      it "will give the timezone(s) #{number[:timezone].join(" or ")}" do
        get URI.encode("/#{number[:string].gsub(/(\[|\])/,"")}")
        last_response.should be_ok
        number[:timezone].any? do |tz|
          last_response.body =~ Regexp.new(Regexp.escape(tz))
        end
      end

    end 
  end
end
