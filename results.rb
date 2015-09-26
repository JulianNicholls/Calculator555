require 'calculator'
require 'term/ansicolor'

# Add a highlighter to the Term::ANSIColor module
module Term
  # ANSIColor inside Term!
  module ANSIColor
    def highlight(str, high = yellow, reset = white)
      high + str + reset
    end
  end
end

# Results renderer for the text-based calculator
class Calc555Results
  include Term::ANSIColor

  def initialize(calculator)
    @calc = calculator
  end

  def render
    show_frequency
    show_duty_cycle
    show_resistors
  end

  private

  def show_frequency
    printf 'Frequency:  ' + highlight('%5.1fHz  ') +
      '(' + highlight('%.1fms') + white + ")\n",
      @calc.frequency, @calc.period_ms
  end

  def show_duty_cycle
    printf 'Duty Ratio: ' + highlight('%5.1f%%') + '   (th: ' +
      highlight('%5.1fms') + ', tl: ' + highlight('%5.1fms') + ")\n\n",
           @calc.duty_ratio_percent, @calc.th_ms, @calc.tl_ms
  end

  def show_resistors
    puts 'Resistors - R1: ' + highlight(resistor_value(@calc.r1_value)) +
      "\n            R2: " + highlight(resistor_value(@calc.r2_value))
  end

  def resistor_value(value)
    if value < 5_000.0
      value.round.to_s + ' Ω'
    elsif value < 1_000_000.0
      (value / 1_000.0).round(2).to_s + ' kΩ'
    else
      (value / 1_000_000.0).round(2).to_s + ' MΩ'
    end
  end
end
