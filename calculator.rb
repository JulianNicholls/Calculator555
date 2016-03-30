require 'capacitor'

# Hold a pair of resistors
ResistorPack = Struct.new(:r1, :r2) do
  def sum
    r1 + r2
  end
end

# Calculate the parameters for a 555 timer.
# : reek:TooManyMethods
# :reek:UncommunicativeModuleName
class Calculator555
  def initialize(capacitor, unit = 'µF')
    raise 'Unit cannot be nil' unless unit

    @capacitor = Capacitor.from_value_and_unit(capacitor.to_f, unit)
    @period    = nil
    @res_pack  = nil
  end

  def set_resistors(r1_value, r2_value)
    @res_pack = ResistorPack.new(r1_value, r2_value)
  end

  def r1_value
    check_resistors

    @res_pack.r1
  end

  def r2_value
    check_resistors

    @res_pack.r2
  end

  alias ra_value r1_value
  alias rb_value r2_value

  def period
    check_resistors

    th + tl
  end

  def period_ms
    period * 1000.0
  end

  def hz
    (1.0 / period)
  end

  alias Hz hz
  alias frequency hz

  def th
    check_resistors
    @capacitor.c_factor * @res_pack.sum
  end

  def th_ms
    th * 1000.0
  end

  def tl
    check_resistors

    @capacitor.c_factor * @res_pack.r2
  end

  def tl_ms
    tl * 1000.0
  end

  def duty_ratio
    (th / (th + tl))
  end

  def duty_ratio_percent
    duty_ratio * 100.0
  end

  # A value less than 1 represents a proportion. Any other value is taken to
  # be a percentage.
  def duty_ratio=(dr_value)
    @duty = (dr_value < 1.0) ? dr_value : (dr_value / 100.0)

    raise 'Duty Cycle must be from 50% to 100%' if @duty < 0.5 || @duty > 1.0

    return unless @period

    calc_resistors
  end

  # A value less than 1 is assumed to be a fraction of a second, any larger
  # value is assumed to be ms. This means that a period of say 1.1s could be
  # specified as 1100 (ms).
  def period=(p_value)
    @period = (p_value < 1.0) ? p_value : (p_value / 1000.0)

    return unless @duty

    calc_resistors
  end

  def hz=(value)
    self.period = 1.0 / value
  end

  alias frequency= hz=

  # As with period= above, a value less than 1 is assumed to be a fraction of
  # a Farad. Any other value is assumed to be a number of uF.
  def cap_value=(value)
    @capacitor = Capacitor.new((value < 1.0) ? value : value * 10**-6)
  end

  private

  def calc_resistors
    new_th = @period * @duty
    new_tl = @period - new_th

    r2_value = new_tl / @capacitor.c_factor

    @res_pack = ResistorPack.new((new_th / @capacitor.c_factor) - r2_value, r2_value)
  end

  def check_resistors
    raise 'R1 and R2 must be set' unless @res_pack
  end
end
