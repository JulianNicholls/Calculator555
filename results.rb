require 'calculator'
require 'term/ansicolor'
require 'rformat'

# Add a highlighter to the Term::ANSIColor module
module Term
  # ANSIColor inside Term!
  module ANSIColor
    # :reek:FeatureEnvy
    def highlight(str, high = yellow, reset = white)
      parts = str.split(/~/)
      colours = [reset, high].cycle
      parts.map { |part| colours.next + part }.join ''
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
    freq    = @calc.frequency
    period  = @calc.period_ms

    if freq > 999.0
      printf highlight("Frequency:   ~%6.3fkHz~  (~%.1fµs~)\n"),
             freq / 1000.0, period * 1000.0
    else
      printf highlight("Frequency:  ~%5.1fHz~  (~%.1fms~)\n"), freq, period
    end
  end

  def show_duty_cycle
    duty  = @calc.duty_ratio_percent
    th_ms = @calc.th_ms
    tl_ms = @calc.tl_ms

    if @calc.frequency > 999.0
      printf(
        highlight("Duty Ratio: ~%5.1f%%~   (th: ~%.3fµs~, tl: ~%.3fµs~)\n\n"),
        duty, th_ms * 1000.0, tl_ms * 1000.0)
    else
      printf(
        highlight("Duty Ratio: ~%5.1f%%~   (th: ~%5.1fms~, tl: ~%5.1fms~)\n\n"),
        duty, th_ms, tl_ms)
    end
  end

  def show_resistors
    puts highlight("Resistors - R1: ~#{ResistorFormatter.str r1_value}~") +
         highlight("\n            R2: ~#{ResistorFormatter.str r2_value}")
  end

  def r1_value
    @calc.r1_value
  end

  def r2_value
    @calc.r2_value
  end
end
