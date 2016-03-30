# Capacitor Class
class Capacitor
  MULTIPLIER = 0.693      # ln(2)

  attr_reader :value

  class << self
    def from_text(entry)
      parts = /(?<value>\d+)\s*(?<unit>[µupn][fF]?)?/.match entry

      unit = parts[:unit] || 'µF'

      unit += 'F' if unit.size == 1

      Capacitor.from_value_and_unit(parts[:value].to_i, unit)
    end

    def from_value_and_unit(value, unit)
      raise 'Bad Unit: #{unit}' unless unit =~ /[upnµ][fF]?/

      case unit[0].downcase
      when 'p' then value *= 10**-12   # Pico
      when 'n' then value *= 10**-9    # Nano
      else
        value *= 10**-6                # Micro
      end

      self.new(value)
    end
  end

  def initialize(value)
    @value = value
  end

  def c_factor
    MULTIPLIER * value
  end
end
