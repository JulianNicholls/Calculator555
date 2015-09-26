require 'minitest/autorun'
require 'minitest/pride'

require './calculator'

# Test class for Calculator555 calculations from set resistors
class Calc555FromResistors < Minitest::Test
  def setup
    @calc = Calculator555.new(22)
    @calc.r1_value = 402
    @calc.r2_value = 6400
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

  def test_tl_without_resistors_set
    calc = Calculator555.new(22)
    assert_raises(Exception) { calc.tl }

    @calc.r1_value = 402
    assert_raises(Exception) { calc.tl }

    calc = Calculator555.new(22)
    @calc.r2_value = 402
    assert_raises(Exception) { calc.tl }
  end

  def test_th_without_resistors_set
    calc = Calculator555.new(22)
    assert_raises(Exception) { calc.th }

    @calc.r1_value = 402
    assert_raises(Exception) { calc.th }

    calc = Calculator555.new(22)
    @calc.r2_value = 402
    assert_raises(Exception) { calc.th }
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
end
