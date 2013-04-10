# encoding: utf-8

require 'csv'
require 'tzinfo'
require 'phonie'

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
    @us_timezones = parse_timezone_csv("/../data/area_codes.csv")
    @short_names = parse_shortname_csv("/../data/short_names.csv")
    @international_timezones = load_country_codes
    Phonie::Phone.default_country_code = '1'
  end

  def convert(number)
    begin
      country_code = extract_country_code(number)
      raise InvalidIntlNumberException unless \
        @international_timezones.has_key? country_code
      tz_list = timezones_from_number(country_code, number)

      # For each relevant timezone, prepare a string showing the current
      # time in that zone.
      results = []
      tz_list.each do |tz|
        result = {}
        result[:time] = tz.now.strftime("%H:%M")
        result[:offset] = timezone_offset(tz)
        result[:timezone] = timezone_name(country_code, tz)
        results << result
      end
      results
    rescue InvalidUSNumberException
      raise ConverterException, 
        "#{number} is not a recognised US telephone number."  
    rescue InvalidIntlNumberException
      raise ConverterException, 
        "#{number} is not a recognised telephone number."  
    rescue UnknownAreaCodeException
      raise ConverterException, 
        "#{number} has an unknown area code."
    end
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

  def load_country_codes
    countries = Phonie::Country.load
    timezones = {}
    countries.each do |c|
      timezones[c.country_code] = TZInfo::Country.get(c.char_3_code).zones
    end
    timezones
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
    raise InvalidIntlNumberException unless ValidNumberLengths.include? number.size
    # Step through the possible valid scenarios.
    case 
    when valid_with_code?(number, USLongCountryCode)
      extract_with_code(number, USLongCountryCode)
    when valid_with_code?(number, USShortCountryCode)
      extract_with_code(number, USShortCountryCode)
    when valid_with_code?(number)
      extract_with_code(number)
    else
      raise InvalidUSNumberException
    end
  end

  def extract_country_code(number)
    # Parse number using Phonie to find the country code if possible.
    pn = Phonie::Phone.parse(number.sub("+", "")) 
    if not pn.nil?
      pn.format("%c") 
    else
      "1"
    end
  end

  def timezones_from_number(country_code, number)
    if country_code == "1" 
      # Within the US, we have a good understanding of how area codes map
      # to timezones, so we need to get the area code.
      area_code = extract_area_code(number)
      # First we check that the area code is in our data...
      @us_timezones.has_key? area_code or raise UnknownAreaCodeException
      # ...then we return a list of relevant timezones for that area code.
      @us_timezones[area_code]
    else
      # Outside the US, we have less complete knowledge of area codes and
      # their correspondence to timezones, so just return a list of
      # relevant timezones for that country.
      @international_timezones[country_code] 
    end
  end

  def timezone_name(country_code, timezone)
    # Can we use a short name for the timezone? Depends on whether the
    # timezone is in the US.
    if country_code == "1"
      # For US numbers, get a friendly short name for the zone.
      long_name = timezone.friendly_identifier.gsub(" - ","/").gsub(" ", "_")
      # Adjust for DST, where appropriate.
      if timezone.current_period.dst?
        @short_names[long_name].first
      else
        @short_names[long_name].last
      end
    else
      # For internatinoal numbers, use the actual timezone name.
      timezone.name
    end
  end

  def timezone_offset(timezone)
    # Get the offset in hours (with a leading zero).
    if timezone.current_period.utc_total_offset >= 0
      "+%02d" % (timezone.current_period.utc_total_offset / 3600)
    else
      "%03d" % (timezone.current_period.utc_total_offset / 3600)
    end
  end

end

class InvalidIntlNumberException < Exception
end

class InvalidUSNumberException < Exception
end

class UnknownAreaCodeException < Exception
end

class ConverterException < Exception
end
