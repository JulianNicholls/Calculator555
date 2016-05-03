# Resistor value formatter
#
# 0-5K    Display in Ohms
# 5K-1M   Display in kOhms to 2DP
# 1M+     Display in MOhhms to 2DP
class ResistorFormatter
  def self.str(value)
    return value.round.to_s + ' Ω' if value < 5_000.0

    return (value / 1_000.0).round(2).to_s + ' kΩ' if value < 1_000_000.0

    (value / 1_000_000.0).round(2).to_s + ' MΩ'
  end
end

# Warn if resistor values are too low (< 150) or
# too high (> 1M)
ResistorWarning = Struct.new(:r1_value, :r2_value) do
  LOW_THRESHOLD   = 150
  HIGH_THRESHOLD  = 1_000_000

  TOO_LOW  = ' is less than 150Ω'.freeze
  TOO_HIGH = ' is more than 1MΩ'.freeze

  DECREASE = ', you should decrease the C1 capacitor.'.freeze
  INCREASE = ', you should increase the C1 capacitor.'.freeze

  def show
    return if r1_value > 150 && r1_value < 1_000_000 &&
              r2_value > 150 && r2_value < 1_000_000

    warn_r1_value
    warn_r2_value
    warn_sum
  end

  def warn_r1_value
    puts 'R1' + TOO_LOW  + decrease_text if r1_value < LOW_THRESHOLD
    puts 'R1' + TOO_HIGH + increase_text if r1_value > HIGH_THRESHOLD
  end

  def warn_r2_value
    puts 'R2' + TOO_LOW  + decrease_text if r2_value < LOW_THRESHOLD
    puts 'R2' + TOO_HIGH + increase_text if r2_value > HIGH_THRESHOLD
  end

  def warn_sum
    puts 'The sum of R1 and R2' + TOO_HIGH + increase_text if
      r1_value + r2_value > HIGH_THRESHOLD
  end

  def decrease_text
    return '' if @decrease_shown

    @decrease_shown = true
    DECREASE
  end

  def increase_text
    return '' if @increase_shown

    @increase_shown = true
    INCREASE
  end
end
