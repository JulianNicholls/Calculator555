# Resistor value formatter
#
# 0-5K    Display in Ohms
# %k-1M   Display in kOhms to 2DP
# 1M+     Display in MOhhms to 2DP
class ResistorFormatter
  def self.str(value)
    if value < 5_000.0
      value.round.to_s + ' Ω'
    elsif value < 1_000_000.0
      (value / 1_000.0).round(2).to_s + ' kΩ'
    else
      (value / 1_000_000.0).round(2).to_s + ' MΩ'
    end
  end
end
