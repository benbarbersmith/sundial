# encoding: utf-8

require 'csv'
require 'tzinfo'

class Converter

  USShortCountryCode = "1"
  USLongCountryCode = "001"

  USShortAreaCodeLength = 2
  USLongAreaCodeLength = 3

  LocalNumberLength = 7

  PrefixLengths = [
    USShortAreaCodeLength,
    USLongAreaCodeLength, 
    USShortAreaCodeLength + USShortCountryCode.size,
    USLongAreaCodeLength + USShortCountryCode.size, 
    USShortAreaCodeLength + USLongCountryCode.size,
    USLongAreaCodeLength + USLongCountryCode.size, 
  ]

  ValidNumberLengths = PrefixLengths.uniq.map do |prefix_length|
    LocalNumberLength + prefix_length
  end

  def initialize 
    @timezones = parse_timezone_csv("/../data/areacodes.csv")
    @shortnames = parse_shortname_csv("/../data/shortnames.csv")
  end

  private

  def parse_timezone_csv(file)
    hash = {}
    CSV.foreach(File.dirname(__FILE__) + file) do |line|
      hash[line.first] = line.last.split("+").map do |tz|
        TZInfo::Timezone.get(tz)
      end
    end
    hash
  end

  def parse_shortname_csv(file)
    hash = {}
    CSV.foreach(File.dirname(__FILE__) + file) do |line|
      hash[line.first] = line[1..-1]
    end
    hash
  end

  def valid_with_code?(number, code="")
    # Check that the number starts with the code under test, and return
    # false if not.
    number.start_with? code or return false
    # Get the expected area code length for a number beginning with the
    # code under test.
    area_code_length = number.size - code.size - LocalNumberLength
    # Check if the calculated area code length is valid.
    valid_length = (area_code_length == USShortAreaCodeLength or \
                    area_code_length == USLongAreaCodeLength)
  end

  def extract_with_code(number, code="")
    # Get the expected area code length.
    area_code_length = number.size - code.size - LocalNumberLength
    # Extract the relevant substring corresponding to the area code.
    number[code.size..area_code_length+code.size-1]
  end

  def extract_area_code(number)
    # Strip the number down to the digits.
    number = number.gsub(/[^\d]+/, '')
    # Unless the number is one of the expected lengths, it's invalid.
    raise InvalidNumberException unless ValidNumberLengths.include? number.size
    # Step through the possible valid scenarios.
    case 
    when valid_with_code?(number, USLongCountryCode)
      extract_with_code(number, USLongCountryCode)
    when valid_with_code?(number, USShortCountryCode)
      extract_with_code(number, USShortCountryCode)
    when valid_with_code?(number)
      extract_with_code(number)
    else
      raise InvalidNumberException
    end
  end

  public

  def convert(number = DefaultNumber)
    begin
      area_code = extract_area_code(number)
      # Check that the area code is in our hash.
      @timezones.has_key? area_code or raise UnknownAreaCodeException

      # For each relevant timezone, prepare a string showing the current
      # time in that zone.
      results = []
      @timezones[area_code].each do |tz|
        result = {}
        # Get the time in 24 hour clock format (HH:MM)/
        result[:time] = tz.now.strftime("%H:%M")
        # Get the offset in hours.
        result[:offset] = tz.current_period.utc_total_offset / 3600
        # Get a shortname for the zone from our hash.
        zone = tz.friendly_identifier.gsub(" - ","/").gsub(" ", "_")
        zone = @shortnames[zone]
        # Adjust for DST, where appropriate.
        if tz.current_period.dst?
          zone = zone.last
        else
          zone = zone.first
        end
        result[:timezone] = zone
        results << result
      end
      results
    rescue InvalidNumberException
      raise ConverterException, 
        "#{number} is not a recognised US telephone number."  
    rescue UnknownAreaCodeException
      raise ConverterException, 
        "#{number} has an unknown area code."
    end
  end

end

class InvalidNumberException < Exception
end

class UnknownAreaCodeException < Exception
end

class ConverterException < Exception
end
