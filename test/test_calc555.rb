require 'minitest/autorun'
require 'minitest/pride'

$LOAD_PATH.unshift(File.expand_path('.'))

require 'calc555'

# Test class for Calculate555 resistor value calculations from
# period/frequency and duty cycle.
class TestTextCalculator < Minitest::Test
  def setup
    @c55 = TextCalculator.new
  end

  def test_decode_cap_entry_accepts_no_unit
    assert_equal [22, 'µF'], @c55.decode_cap_entry('22')
  end

  def test_decode_cap_entry_accepts_unit_with_no_f
    assert_equal [22, 'nF'], @c55.decode_cap_entry('22n')
  end
end
