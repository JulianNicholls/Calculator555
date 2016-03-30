require 'minitest/autorun'
require 'minitest/pride'

$LOAD_PATH.unshift(File.expand_path('.'))

require 'capacitor'

# Test class for Capacitor.
class TestCapacitor < Minitest::Test
  def test_from_text_no_unit_implies_uf
    assert_equal 22 * 10**-6, Capacitor.from_text('22').value
  end

  def test_from_text_accepts_unit_with_no_f
    assert_equal 22 * 10**-9, Capacitor.from_text('22n').value
  end

  def test_from_vau_with_nil_unit_is_illegal
    assert_raises(Exception) { Capacitor.from_value_and_unit(22) }
  end

  def test_from_vau_with_bad_unit_is_illegal
    assert_raises(Exception) { Capacitor.from_value_and_unit('22', 'zf') }
  end

  def test_uf_convert
    calc = Capacitor.from_value_and_unit(47, 'uF')

    assert_equal 47.0 * 10**-6, calc.value
  end

  def test_mu_f_convert
    calc = Capacitor.from_value_and_unit(47, 'µF')

    assert_equal 47.0 * 10**-6, calc.value
  end

  def test_nf_convert
    calc = Capacitor.from_value_and_unit(47, 'nF')

    nano = 10**-9
    assert_in_delta 47.0 * nano, calc.value, nano
  end

  def test_pf_convert
    calc = Capacitor.from_value_and_unit(47, 'pF')

    assert_equal 47.0 * 10**-12, calc.value
  end

  def test_case_insensitivity
    calc = Capacitor.from_value_and_unit(47, 'pf')

    assert_equal 47.0 * 10**-12, calc.value
  end

  def test_optionality_of_f
    calc = Capacitor.from_value_and_unit(47, 'p')

    assert_equal 47.0 * 10**-12, calc.value
  end
end
