#!/usr/bin/env ruby -I.

require 'calculator'
require 'term/ansicolor'
require 'results'

# A text-based 555 timer calculator
class TextCalculator
  include Term::ANSIColor

  FUNCTIONS = {
    R:  -> { calculate_cycle_times },
    P:  -> { calculate_resistors_from_period },
    F:  -> { calculate_resistors_from_frequency },
    Q:  -> { exit }
  }

  UNRECOGNISED = -> { puts "\nUnrecognised Option" }

  def run
    show_title
    initialize_calculator

    loop do
      op = input(run_prompt)[0].upcase.to_sym

      instance_exec(&FUNCTIONS.fetch(op, UNRECOGNISED))
    end
  end

  private

  def run_prompt
    "\nEnter Duty Ratio and (" +
      highlight('P') + ')eriod or (' +
      highlight('F') + ')requency, (' +
      highlight('R') + ')esistor values, or (' +
      highlight('Q') + ')uit'
  end

  def show_title
    puts highlight("555 Timer Calculator\n====================\n", cyan)
  end

  def initialize_calculator
    entered_cap = input('Capacitor: (' + highlight('22µF') + ')')

    cap = entered_cap == '' ? [22, 'µF'] : decode_cap_entry(entered_cap)

    @calc = Calculator555.new(*cap)
  end

  def calculate_cycle_times
    @calc.r1_value = input_float("\nEnter the R1 value", 1)
    @calc.r2_value = input_float('Enter the R2 value', 1)

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

    Calc555Results.new(@calc).render
  end

  def input(prompt)
    print white + prompt + '? ' + yellow

    $stdin.gets.chomp
  end

  def input_float(prompt, min = 0.0, max = 10.0**25)
    loop do
      value = input(prompt).to_f

      return value if value.between?(min, max)

      print "\n" + highlight('The value must be between ', red, yellow) +
        "#{min}" + highlight(' and ', red, yellow) + "#{max}\n"
    end
  end

  def decode_cap_entry(entry)
    parts = /(?<value>\d+)\s*(?<unit>[µupn][fF])/.match entry

    [parts[:value].to_i, parts[:unit]]
  end
end

TextCalculator.new.run
