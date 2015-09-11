require 'minitest/autorun'
require 'minitest/pride'

require './calculator'

# Test class for Calculator555
class Calc555Test < Minitest::Test
  def setup
    @calc = Calculator555.new(22)
    @calc.r1_value = 402
    @calc.r2_value = 6400
  end

  def test_raw_initialize
    calc = Calculator555.new(22) # Implied micro F

    assert_equal 22.0 * 10**-6, calc.cap_value
  end

  def test_raw_initialize_with_string
    calc = Calculator555.new('22') # Implied micro F

    assert_equal 22.0 * 10**-6, calc.cap_value
  end

  def test_uf_convert
    calc = Calculator555.new(47, 'uF')

    assert_equal 47.0 * 10**-6, calc.cap_value
  end

  def test_mu_f_convert
    calc = Calculator555.new(47, 'µF')

    assert_equal 47.0 * 10**-6, calc.cap_value
  end

  def test_nf_convert
    calc = Calculator555.new(47, 'nF')

    assert_equal 47.0 * 10**-9, calc.cap_value
  end

  def test_pf_convert
    calc = Calculator555.new(47, 'pF')

    assert_equal 47.0 * 10**-12, calc.cap_value
  end

  def test_ra
    assert_equal 402, @calc.ra_value
  end

  def test_rb
    assert_equal 6400, @calc.rb_value
  end

  def test_th_with_explicit_resistors
    assert_in_delta 0.104, @calc.th, 0.0005
  end

  def test_tl_with_explicit_resistors
    assert_in_delta 0.098, @calc.tl, 0.0005
  end

  def test_th_ms
    assert_in_delta 104, @calc.th_ms, 0.5
  end

  def test_tl_ms
    assert_in_delta 98, @calc.tl_ms, 0.5
  end

  def test_period_with_explicit_resistors
    assert_in_delta 0.202, @calc.period, 0.0005
  end

  def test_period_ms
    assert_in_delta 202, @calc.period_ms, 0.5
  end

  def test_frequency_hzs_with_explicit_resistors
    assert_in_delta 4.95, @calc.hz, 0.0005
    assert_in_delta 4.95, @calc.Hz, 0.0005
    assert_in_delta 4.95, @calc.frequency, 0.0005
  end

  def test_duty_ratio_with_explicit_resistors
    assert_in_delta 0.515, @calc.duty_ratio, 0.0005
  end

  def test_duty_ratio_percent
    assert_in_delta 51.5, @calc.duty_ratio_percent, 0.05
  end

  def test_calculate_resistors_duty_ratio_period
    @calc.duty_ratio = 0.55   # 55%
    @calc.period = 0.200      # 200ms

    assert_in_delta 5903, @calc.r2_value, 1
    assert_in_delta 1312, @calc.r1_value, 1
  end

  def test_calculate_resistors_duty_ratio_percent_period
    @calc.duty_ratio = 55   # 55%
    @calc.period = 0.200    # 200ms

    assert_in_delta 5903, @calc.r2_value, 1
    assert_in_delta 1312, @calc.r1_value, 1
  end

  def test_calculate_resistors_duty_ratio_percent_period_ms
    @calc.duty_ratio = 55  # 55%
    @calc.period = 200     # 200ms

    assert_in_delta 5903, @calc.r2_value, 1
    assert_in_delta 1312, @calc.r1_value, 1
  end

  def test_calculate_resistors_duty_ratio_percent_frequency
    @calc.duty_ratio = 55  # 55%
    @calc.frequency = 5    # 5 Hz

    assert_in_delta 5903, @calc.r2_value, 1
    assert_in_delta 1312, @calc.r1_value, 1
  end

  def test_calculate_resistors_duty_ratio_percent_hz
    @calc.duty_ratio = 55   # 55%
    @calc.hz = 5            # 5 Hz

    assert_in_delta 5903, @calc.r2_value, 1
    assert_in_delta 1312, @calc.r1_value, 1
  end
end
