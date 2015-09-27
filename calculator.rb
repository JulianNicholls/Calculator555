# Calculate the parameters for a 555 timer.
class Calculator555
  MULTIPLIER = 0.693

  attr_reader :cap_value
  attr_accessor :r1_value, :r2_value

  def initialize(capacitor, unit = 'µF')
    @cap_value = interpret(capacitor.to_f, unit)
  end

  def period
    check_resistors

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
    check_resistors
    (c_factor * (r1_value + r2_value)).round(3)
  end

  def th_ms
    th * 1000.0
  end

  def tl
    check_resistors
    (c_factor * r2_value).round(3)
  end

  def tl_ms
    tl * 1000.0
  end

  def duty_ratio
    (th / (th + tl)).round(3)
  end

  def duty_ratio_percent
    duty_ratio * 100.0
  end

  # A value less than 1 represents a proportion. Any other value is taken to
  # be a percentage.
  def duty_ratio=(value)
    @duty = (value < 1.0) ? value : (value / 100.0)

    fail 'Duty Cycle must be from 50% to 100%' if @duty < 0.5 || @duty > 1.0

    return if @period.nil?

    calc_resistors
  end

  # A value less than 1 is assumed to be a fraction of a second, any larger
  # value is assumed to be ms. This means that a period of say 1.1s could be
  # specified as 1100 (ms).
  def period=(value)
    @period = (value < 1.0) ? value : (value / 1000.0)

    return if @duty.nil?

    calc_resistors
  end

  def hz=(value)
    self.period = 1.0 / value
  end

  alias_method :frequency=, :hz=

  def ra_value
    r1_value
  end

  def rb_value
    r2_value
  end

  # As with period= above, a value less than 1 is assumed to be a fraction of
  # a Farad. Any other value is assumed to be a number of uF.
  def cap_value=(value)
    @cap_value = (value < 1.0) ? value : value * 10**-6
  end

  private

  def calc_resistors
    new_th = @period * @duty
    new_tl = @period - new_th

    self.r2_value = (new_tl / c_factor).round(1)
    self.r1_value = ((new_th / c_factor) - r2_value).round(1)
  end

  def c_factor
    MULTIPLIER * cap_value
  end

  def check_resistors
    fail 'R1 and R2 must be set' unless r1_value && r2_value
  end

  def interpret(value, unit)
    fail 'Bad Unit: #{unit}' unless unit =~ /[upnµ][fF]/

    case unit[0].downcase
    when 'p' then value * 10**-12   # Pico
    when 'n' then value * 10**-9    # Nano
    else
      value * 10**-6                # Micro
    end
  end
end
