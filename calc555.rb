#!/usr/bin/env ruby -I. -w

require 'calculator'
require 'term/ansicolor'

class TextCalculator
  include Term::ANSIColor

  def run
    show_title
    initialize_calculator

    loop do
      op = input "\nEnter Duty Cycle and (P)eriod or (F)requency, (R)esistor values, or (Q)uit"

      case op[0].upcase
      when 'R'  then calculate_cycle_times
      when 'P'  then calculate_resistors_from_period
      when 'F'  then calculate_resistors_from_frequency
      when 'Q'  then exit
      end
    end
  end

  private

  def show_title
    puts cyan + bold + "555 Timer Calculator\n====================\n" + reset
  end

  def initialize_calculator
    entered_cap = input 'Capacitor: (22µF)'

    cap = entered_cap == '' ? [22, 'µF'] : decode_cap_entry(entered_cap)

    @calc = Calculator555.new(*cap)
  end

  def calculate_cycle_times
    @calc.r1 = input_float "\nEnter the R1 value"
    @calc.r2 = input_float 'Enter the R2 value'

    show_results
  end

  def calculate_resistors_from_period
    enter_duty_cycle
    @calc.period = input_float "Enter the Period in ms"

    show_results
  end

  def calculate_resistors_from_frequency
    enter_duty_cycle
    @calc.frequency = input_float "Enter the Frequency in Hz"

    show_results
  end

  def enter_duty_cycle
    @calc.duty_cycle = input_float "\nEnter the Duty Cycle Percentage"
  end

  def show_results
    puts bold + cyan + "\n    Calculated Values\n    =================\n" + yellow
    printf "Frequency:  %5.1fHz  (%.1fms)\n", @calc.frequency, @calc.period_ms
    printf "Duty Cycle: %5.1f%%   (tl: %5.1fms, th: %5.1fms)\n\n",
           @calc.duty_cycle_percent, @calc.th_ms, @calc.tl_ms

    puts 'Resistors - R1: ' + resistor_value(@calc.r1) +
         ', R2: ' + resistor_value(@calc.r2)
  end

  def resistor_value(value)
    if value < 10_000.0
      value.to_s
    elsif value < 1_000_000.0
      (value / 1000.0).round(2).to_s + 'K'
    else
      (value / 1_000_000.0).round(2).to_s + 'M'
    end
  end

  def input(prompt)
    print yellow + bold + prompt + '? ' + white

    $stdin.gets.chomp
  end

  def input_float(prompt)
    input(prompt).to_f
  end

  def decode_cap_entry(entry)
    parts = /(?<value>\d+)\s*(?<unit>[µupn][fF])/.match entry

    [parts[:value].to_i, parts[:unit]]
  end
end

TextCalculator.new.run
