require 'minitest/autorun'
require 'minitest/pride'

require './calculator'

class Calc555Test < Minitest::Test
  def setup
    @calc = Calculator555.new(22)
    @calc.r1 = 402
    @calc.r2 = 6400
  end

  def test_raw_initialize
    calc = Calculator555.new(22)  # Implied µF

    assert_equal calc.c, 22 * 10**-6
  end

  def test_uf_convert
    calc = Calculator555.new(47, 'uF')

    assert_equal calc.c, 47 * 10**-6
  end

  def test_mu_f_convert
    calc = Calculator555.new(47, 'µF')

    assert_equal calc.c, 47 * 10**-6
  end

  def test_nf_convert
    calc = Calculator555.new(47, 'nF')

    assert_equal calc.c, 47 * 10**-9
  end

  def test_pf_convert
    calc = Calculator555.new(47, 'pF')

    assert_equal calc.c, 47 * 10**-12
  end

  def test_ra
    assert_equal 402, @calc.ra
    assert_equal @calc.r1, @calc.ra
  end

  def test_rb
    assert_equal 6400, @calc.rb
    assert_equal @calc.r2, @calc.rb
  end

  def test_th_with_explicit_r1_r2
    assert_in_delta 0.104, @calc.th, 0.0005
  end

  def test_tl_with_explicit_r1_r2
    assert_in_delta 0.098, @calc.tl, 0.0005
  end

  def test_period_with_explicit_r1_r2
    assert_in_delta 0.202, @calc.period, 0.0005
  end

  def test_frequency_hz_Hz_with_explicit_r1_r2
    assert_in_delta 4.95, @calc.hz, 0.0005
    assert_in_delta 4.95, @calc.Hz, 0.0005
    assert_in_delta 4.95, @calc.frequency, 0.0005
  end

  def test_duty_cycle_with_explicit_r1_r2
    assert_in_delta 0.485, @calc.duty_cycle, 0.0005
  end

  def test_calculate_r1_r2_duty_cycle_period
    @calc.duty_cycle = 0.55   # 55%
    @calc.period = 0.200      # 200ms

    assert_in_delta 5903, @calc.r2, 1
    assert_in_delta 1312, @calc.r1, 1
  end

  def test_calculate_r1_r2_duty_cycle_percent_period
    @calc.duty_cycle = 55   # 55%
    @calc.period = 0.200    # 200ms

    assert_in_delta 5903, @calc.r2, 1
    assert_in_delta 1312, @calc.r1, 1
  end

  def test_calculate_r1_r2_duty_cycle_percent_period_ms
    @calc.duty_cycle = 55  # 55%
    @calc.period = 200     # 200ms

    assert_in_delta 5903, @calc.r2, 1
    assert_in_delta 1312, @calc.r1, 1
  end

  def test_calculate_r1_r2_duty_cycle_percent_frequency
    @calc.duty_cycle = 55  # 55%
    @calc.frequency = 5    # 200ms

    assert_in_delta 5903, @calc.r2, 1
    assert_in_delta 1312, @calc.r1, 1
  end

  def test_calculate_r1_r2_duty_cycle_percent_hz
    @calc.duty_cycle = 55  # 55%
    @calc.frequency = 5    # 200ms

    assert_in_delta 5903, @calc.r2, 1
    assert_in_delta 1312, @calc.r1, 1
  end
end
