require 'minitest/autorun'
require 'minitest/pride'

$LOAD_PATH.unshift(File.expand_path('.'))

require 'calculator'

# Test class for Calculate555 resistor value calculations from
# period/frequency and duty cycle.
class Calc555Resistors < Minitest::Test
  def setup
    @calc = Calculator555.new('22')
    @calc.set_resistors(402, 6400)
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

  def test_calculate_resistors_duty_ratio_percent_large_frequency
    calc = Calculator555.new('100nf')
    calc.duty_ratio = 51      # 51%
    calc.frequency  = 32_768  # 32768 Hz

    assert_in_delta 216, calc.r2_value, 1
    assert_in_delta 9, calc.r1_value, 1
  end

  def test_stability_with_ksize_frequency
    @calc.duty_ratio = 55   # 55%
    @calc.frequency  = 999  # 999 Hz

    assert_in_delta 0.001, @calc.period, 0.0005
    assert_in_delta 999, @calc.frequency, 1
  end

  def test_stability_with_10ksize_frequency
    @calc.duty_ratio = 55    # 55%
    @calc.frequency  = 9999  # 9999 Hz

    assert_in_delta 0.0001, @calc.period, 0.00005
    assert_in_delta 9999, @calc.frequency, 1
  end

  def test_stability_with_really_large_frequency
    @calc.duty_ratio = 55      # 55%
    @calc.frequency  = 32_768  # 32768 Hz

    assert_in_delta 0.00003, @calc.period, 0.00001
    assert_equal 32_768, @calc.frequency
  end

  # :reek:DuplicateMethodCall: { max_calls: 3 }
  def test_out_of_range_duty_ratio_low
    assert_raises(Exception) { @calc.duty_ratio = 0.49 }
    assert_raises(Exception) { @calc.duty_ratio = 49 }
  end

  # :reek:DuplicateMethodCall: { max_calls: 3 }
  def test_out_of_range_duty_ratio_high
    assert_raises(Exception) { @calc.duty_ratio = 1.01 }
    assert_raises(Exception) { @calc.duty_ratio = 101 }
  end
end
