# Calculate the parameters for a 555 timer.
class Calculator555
  MULTIPLIER = 0.693

  attr_reader :c
  attr_accessor :r1, :r2

  def initialize(capacitor, unit = 'µF')
    @c = interpret(capacitor.to_f, unit)
  end

  def period
    check_r1_r2

    th + tl
  end

  def period_ms
    period * 1000.0
  end

  def hz
    (1.0 / period).round(2)
  end

  alias_method :Hz, :hz
  alias_method :frequency, :hz

  def th
    check_r1_r2
    (MULTIPLIER * (r1 + r2) * c).round(3)
  end

  def th_ms
    th * 1000.0
  end

  def tl
    check_r1_r2
    (MULTIPLIER * r2 * c).round(3)
  end

  def tl_ms
    tl * 1000.0
  end

  def duty_cycle
    (th / (th + tl)).round(3)
  end

  def duty_cycle_percent
    duty_cycle * 100.0
  end

  def duty_cycle=(value)
    @duty = (value < 1) ? value : (value / 100.0)

    return if @period.nil?

    calc_r1_r2
  end

  def period=(value)
    @period = (value < 1.0) ? value : (value / 1000.0)

    return if @duty.nil?

    calc_r1_r2
  end

  def hz=(value)
    self.period = 1.0 / value
  end

  alias_method :frequency=, :hz=

  def ra
    r1
  end

  def rb
    r2
  end

  def calc_r1_r2
    new_th = @period * @duty
    new_tl = @period - new_th

    @r2 = (new_tl / (MULTIPLIER * c)).round(1)
    @r1 = ((new_th / (MULTIPLIER * c)) - r2).round(1)
  end

  private

  def check_r1_r2
    fail 'R1 and R2 must be set' if r1.nil? || r2.nil?
  end

  def interpret(value, unit)
    fail 'Bad Unit: #{unit}' unless unit =~ /[upnµ]f/i

    case unit[0].downcase
    when 'p' then value * 10**-12   # Pico
    when 'n' then value * 10**-9    # Nano
    else
      value * 10**-6                # Micro
    end
  end
end
