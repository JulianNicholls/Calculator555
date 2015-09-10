#!/usr/bin/env ruby -I.

require 'calculator'
require 'term/ansicolor'

# A text-based 555 timer calculator
class TextCalculator
  include Term::ANSIColor

  FUNCTIONS = {
    R:  -> { calculate_cycle_times },
    P:  -> { calculate_resistors_from_period },
    F:  -> { calculate_resistors_from_frequency },
    Q:  -> { exit }
  }

  def run
    show_title
    initialize_calculator

    loop do
      op = input(run_prompt)[0].upcase.to_sym

      instance_exec(&FUNCTIONS[op]) if FUNCTIONS.key? op
    end
  end

  private

  def run_prompt
    "\nEnter Duty Ratio and (" + highlight('P') + ')eriod or (' +
      highlight('F') + ')requency, (' + highlight('R') +
      ')esistor values, or (' + highlight('Q') + ')uit'
  end

  def show_title
    puts highlight("555 Timer Calculator\n====================\n", cyan)
  end

  def initialize_calculator
    entered_cap = input 'Capacitor: (' + highlight('22µF') + ')'

    cap = entered_cap == '' ? [22, 'µF'] : decode_cap_entry(entered_cap)

    @calc = Calculator555.new(*cap)
  end

  def calculate_cycle_times
    @calc.r1 = input_float("\nEnter the R1 value", 1)
    @calc.r2 = input_float('Enter the R2 value', 1)

    show_results
  end

  def calculate_resistors_from_period
    # Allow 10us to 1 minute
    @calc.period = input_float("\nEnter the Period in ms", 0.000001, 60_000)
    enter_duty_ratio

    show_results
  end

  def calculate_resistors_from_frequency
    # Allow 1 in 60 seconds up to 100kHz
    @calc.frequency = input_float("\nEnter the Frequency in Hz", 0.016, 100_000)
    enter_duty_ratio

    show_results
  end

  def enter_duty_ratio
    @calc.duty_ratio = input_float('Enter the Duty Ratio', 50, 99.9)
  end

  def show_results
    puts highlight("\n    Calculated Values\n    =================\n", cyan)

    printf 'Frequency:  ' + highlight('%5.1fHz  ') + '(' + highlight('%.1fms') +
      white + ")\n", @calc.frequency, @calc.period_ms

    printf 'Duty Ratio: ' + highlight('%5.1f%%') + '   (th: ' +
      highlight('%5.1fms') + ', tl: ' + highlight('%5.1fms') + ")\n\n",
           @calc.duty_ratio_percent, @calc.th_ms, @calc.tl_ms

    puts 'Resistors - R1: ' + highlight(resistor_value(@calc.r1)) +
      "\n            R2: " + highlight(resistor_value(@calc.r2))
  end

  def resistor_value(value)
    if value < 5_000.0
      value.to_s + 'Ω'
    elsif value < 1_000_000.0
      (value / 1000.0).round(2).to_s + 'kΩ'
    else
      (value / 1_000_000.0).round(2).to_s + 'MΩ'
    end
  end

  def input(prompt)
    print white + prompt + '? ' + yellow

    $stdin.gets.chomp
  end

  def input_float(prompt, min = 0.0, max = 10.0**25)
    loop do
      value = input(prompt).to_f

      return value if value.between?(min, max)

      print "\n" + red + 'The value must be between ' + yellow + "#{min}" +
        red + ' and ' + yellow + "#{max}\n"
    end
  end

  def decode_cap_entry(entry)
    parts = /(?<value>\d+)\s*(?<unit>[µupn][fF])/.match entry

    [parts[:value].to_i, parts[:unit]]
  end

  def highlight(str, high = yellow, reset = white)
    high + str + reset
  end
end

TextCalculator.new.run