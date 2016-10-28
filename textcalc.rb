#!/usr/bin/env ruby -I.
# frozen_string_literal: true

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

  private

  def run_prompt
    highlight("\nEnter Duty Ratio and (~P~)eriod or (~F~)requency,\n" \
              "(~R~)esistor values, (~C~)hange Capacitor or\n(~Q~)uit")
  end

  def show_title
    puts highlight("~  555 Timer Calculator\n  ====================\n\n", cyan)
  end

  def initialize_calculator
    entered_cap = input(highlight('Capacitor: (~10µF~)'))

    entered_cap = '10µF' if entered_cap == ''

    @calc = Calculator555.new(entered_cap)
  end

  def calculate_cycle_times
    r1_value = input_float("\nEnter the R1 value", 150, 1_000_000,
                           'Resistors should be between 150Ω and 1MΩ')
    r2_value = input_float('Enter the R2 value', 150, 1_000_000,
                           'Resistors should be between 150Ω and 1MΩ')

    @calc.set_resistors(r1_value, r2_value)

    show_results
  end

  def calculate_resistors_from_period
    # Allow 10us to 1 minute
    @calc.period = input_float("\nEnter the Period in ms", 0.00001, 60_000)
    enter_duty_ratio

    show_results
  end

  def calculate_resistors_from_frequency
    # Allow 1 in 10 seconds up to 300kHz
    @calc.frequency = input_float("\nEnter the Frequency in Hz", 0.1, 300_000)
    enter_duty_ratio

    show_results
  end

  def enter_duty_ratio
    @calc.duty_ratio = input_float('Enter the Duty Ratio', 0.01, 99.99)
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

  # :reek:LongParameterList
  def input_float(prompt, min = 0.0, max = 10.0**25,
                  message = "The value must be between ~#{min}~ and ~#{max}")
    loop do
      value = input(prompt).to_f

      return value if value.between?(min, max)

      puts "\n" + highlight(message, reset + yellow, bold + red)
    end
  end
end

# Run the interactive calculator if called from here.
TextCalculator.new.run if $PROGRAM_NAME == __FILE__
