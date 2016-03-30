require 'minitest/autorun'
require 'minitest/pride'

$LOAD_PATH.unshift(File.expand_path('.'))

require 'calc555'

# Test class for Capacitor Decoder.
class Calc555Decoder < Minitest::Test
  def test_decode_cap_entry_accepts_no_unit
    assert_equal [22, 'µF'], CapacitorDecoder.call('22')
  end

  def test_decode_cap_entry_accepts_unit_with_no_f
    assert_equal [22, 'nF'], CapacitorDecoder.call('22n')
  end
end
