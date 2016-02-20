require 'minitest/autorun'
require 'minitest/pride'

require './calculator'

# Test class for Calculator555 initialisation
class Calc555Init < Minitest::Test
  def test_raw_initialize
    calc = Calculator555.new(22) # Implied micro F

    assert_equal 22.0 * 10**-6, calc.cap_value
  end

  def test_raw_initialize_with_nil_unit_is_illegal
    assert_raises(Exception) { Calculator555.new(22, nil) }
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

  def test_case_sensitivity
    calc = Calculator555.new(47, 'pf')

    assert_equal 47.0 * 10**-12, calc.cap_value
  end

  def test_initialize_with_bad_unit
    assert_raises(Exception) { Calculator555.new('22', 'zf') }
  end
end
