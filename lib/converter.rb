# encoding: utf-8

require 'csv'
require 'tzinfo'

class Converter

  DefaultNumber = "01865 203192"
  NumberLengthWithLongCountryCode = 13
  NumberLengthWithShortCountryCode = 11 
  NumberLengthWithoutCountryCode = 10
  USShortCountryCode = "1"
  USLongCountryCode = "001"
  USShorterAreaCodes = ["52", "55"]
  AreaCodeLength = 3
  
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

  def extract_area_code(number)
    number = number.gsub(/[^\d]+/, '')
    case number.size

    when NumberLengthWithShortCountryCode
      number.start_with? USShortCountryCode or raise InvalidNumberException
      number.sub(USShortCountryCode, '')[0..AreaCodeLength-1]

    when NumberLengthWithLongCountryCode
      number.start_with? USLongCountryCode or raise InvalidNumberException
      number.sub(USLongCountryCode, '')[0..AreaCodeLength-1]

    when NumberLengthWithoutCountryCode
      if number.start_with? "152" or number.start_with? "155"
        number[1..AreaCodeLength-1]
      else
        number[0..AreaCodeLength-1]
      end

    when NumberLengthWithLongCountryCode-1
      if USShorterAreaCodes.any? { |code| number.start_with? (USLongCountryCode + code) }
        number.sub(USLongCountryCode, '')[0..AreaCodeLength-2]
      else
        raise InvalidNumberException
      end 

    when NumberLengthWithoutCountryCode-1
      if USShorterAreaCodes.any? { |code| number.start_with? code }
        number[0..AreaCodeLength-2]
      else
        raise InvalidNumberException
      end

    else
      raise InvalidNumberException

    end
  end

  public

  def convert(number = DefaultNumber)
    begin
      area_code = extract_area_code(number)
      @timezones.has_key? area_code or raise UnknownAreaCodeException
      @timezones[area_code].map do |tz|
        time = tz.now.strftime("%H:%M")
        offset = tz.current_period.utc_total_offset / 3600
        zone = tz.friendly_identifier.gsub(" - ","/").gsub(" ", "_")
        zone = @shortnames[zone]
        if tz.current_period.dst?
          zone = zone.last
        else
          zone = zone.first
        end
        "#{time} #{zone} (GMT #{'+' if offset > 0}#{offset})"
      end
    rescue InvalidNumberException
      "#{number} is not a recognised US telephone number."  
    rescue UnknownAreaCodeException
      "#{number} has an unknown area code."
    end
  end

end

class InvalidNumberException < Exception
end

class UnknownAreaCodeException < Exception
end
