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
    return show_above_1khz if @calc.frequency > 999.0

    printf(
      highlight("Duty Cycle: ~%5.1f%%~   (th: ~%.1fms~, tl: ~%.1fms~)\n\n"),
      @calc.duty_ratio_percent, @calc.th_ms, @calc.tl_ms)
  end

  def show_above_1khz
    printf(
      highlight("Duty Cycle: ~%5.1f%%~   (th: ~%.1fµs~, tl: ~%.1fµs~)\n\n"),
      @calc.duty_ratio_percent, @calc.th_ms * 1000.0, @calc.tl_ms * 1000.0)
  end

  def show_resistors
    puts highlight("Resistors - R1: ~#{ResistorFormatter.str r1_value}~") +
         highlight("\n            R2: ~#{ResistorFormatter.str r2_value}~\n\n")

    ResistorWarning.new(r1_value, r2_value).show
  end

  def r1_value
    @calc.r1_value
  end

  def r2_value
    @calc.r2_value
  end
end
