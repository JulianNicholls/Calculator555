class Calculator555
  MULTIPLIER = 0.693

  attr_accessor r1, r2

  def initialize(capacitor, unit = 'uF')
    @c = interpret(capacitor, unit)
  end

  def period
    check_r1_r2

    MULTIPLER * r1 * 2 * r2 * @c
  end

  def hz
    1 / period
  end

  def th
    check_r1_r2
    MULTIPLIER * (r1 + r2) * @c
  end

  def tl
    check_r1_r2
    MULTIPLIER * r2 * c
  end

  def duty_cycle
    tl / (th + tl)
  end

  def duty_cycle=(value)
    @duty = if value < 1
              value
            else
              value / 100
            end
  end

  def hz=(value)
    @hz = value
  end

  alias_method :Hz, :hz

  def ra
    r1
  end

  def rb
    r2
  end

  private

  def check_r1_r2
    fail 'R1 and R2 must be set' if @r1.nil || @r2.nil
  end

  def interpret(value, unit)
    return value if unit.nil?

    fail "Bad Unit: #{unit}" unless unit =~ /[upnµ]f/i

    case unit[0].downcase
    when p then value * 10 ** -12   # Pico
    when n then value * 10 ** -9    # Nano
    else
      value * 10 ** -6              # Micro
    end
  end
end
