# Resistor value formatter
#
# 0-10    Display IN Ohms to 3DP with a warning
# 1-5K    Display in Ohms
# 5K-1M   Display in kOhms to 2DP
# 1M+     Display in MOhhms to 2DP
class ResistorFormatter
  def self.str(value)
    if value < 10.0
      value.round(3).to_s +  ' Ω - Warning Low Value'
    elsif value < 5_000.0
      value.round.to_s + ' Ω'
    elsif value < 1_000_000.0
      (value / 1_000.0).round(2).to_s + ' kΩ'
    else
      (value / 1_000_000.0).round(2).to_s + ' MΩ'
    end
  end
end
