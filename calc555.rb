#!/usr/bin/env ruby -I.

require 'calculator'
require 'term/ansicolor'
require 'results'

# A text-based 555 timer calculator
class TextCalculator
  include Term::ANSIColor

  FUNCTIONS = {
    C:  -> { initialize_calculator },
    F:  -> { calculate_resistors_from_frequency },
    P:  -> { calculate_resistors_from_period },
    R:  -> { calculate_cycle_times },
    Q:  -> { exit }
  }.freeze

  UNRECOGNISED = -> { puts "\nUnrecognised Option" }

  def run
    show_title
    initialize_calculator

    loop do
      op = input_op(run_prompt)

      instance_exec(&FUNCTIONS.fetch(op, UNRECOGNISED))
    end
  end

  def decode_cap_entry(entry)
    parts = /(?<value>\d+)\s*(?<unit>[µupn][fF]?)?/.match entry

    unit = parts[:unit] || 'µF'

    unit += 'F' if unit.size == 1

    [parts[:value].to_i, unit]
  end

  private

  def run_prompt
    highlight("\nEnter Duty Ratio and (~P~)eriod or (~F~)requency,\n" \
              "(~R~)esistor values, (~C~)hange Capacitor or\n(~Q~)uit")
  end

  def show_title
    puts highlight("~  555 Timer Calculator\n  ====================\n\n", cyan)
  end

  def initialize_calculator
    entered_cap = input(highlight('Capacitor: (~22µF~)'))

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
    @calc.period = input_float("\nEnter the Period in ms", 0.00001, 60_000)
    enter_duty_ratio

    show_results
  end

  def calculate_resistors_from_frequency
    # Allow 1 in 60 seconds up to 100kHz
    @calc.frequency = input_float("\nEnter the Frequency in Hz", 1, 100_000)
    enter_duty_ratio

    show_results
  end

  def enter_duty_ratio
    @calc.duty_ratio = input_float('Enter the Duty Ratio', 50, 99.99)
  end

  def show_results
    puts highlight("\n    ~Calculated Values\n    =================\n\n", cyan)

    Calc555Results.new(@calc).render
  end

  def input(prompt)
    print white + prompt + '? ' + yellow

    $stdin.gets.chomp
  end

  def input_op(prompt)
    input(prompt)[0].upcase.to_sym
  end

  def input_float(prompt, min = 0.0, max = 10.0**25)
    loop do
      value = input(prompt).to_f

      return value if value.between?(min, max)

      puts "\n" +
           highlight("The value must be between ~#{min}~ and ~#{max}",
                     reset + yellow, bold + red)
    end
  end
end

# Run the interactive calculator if called from here.
TextCalculator.new.run if $PROGRAM_NAME == __FILE__
