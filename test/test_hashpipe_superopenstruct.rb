require 'helper'

class TestHashpipeSuperOpenStruct < Test::Unit::TestCase
  def test_01_construct
    h = create_sos
    assert(h)
    assert_kind_of(HashPipe::SuperOpenStruct, h)
    assert_respond_to(h, :lock!)
  end
end
