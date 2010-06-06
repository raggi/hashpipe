require 'helper'

class TestHashpipeSuperOpenStruct < Test::Unit::TestCase
  def test_01_construct
    h = create_sos
    assert(h)
    assert_kind_of(HashPipe::SuperOpenStruct, h)
    assert_respond_to(h, :lock!)
  end

  def test_02_accessors
    h = create_sos

    h.foo = "bar"
    assert_equal(h.foo,    "bar")
    assert_equal(h[:foo],  "bar")
    assert_equal(h['foo'], "bar")
    
    h.bar = "baz"
    assert_equal(h.bar,    "baz")
    assert_equal(h[:bar],  "baz")
    assert_equal(h['bar'], "baz")
  end

  def test_03_lock
    h = create_sos

    h.foo = "bar"
    h.lock!

    assert_raises(ArgumentError.new("this openstruct is locked.")) do 
      h.bar = "baz"
    end

    assert_equal(h.foo,    "bar")
    assert_equal(h[:foo],  "bar")
    assert_equal(h['foo'], "bar")
  end

  def test_04_overwrite
    h = create_sos
    assert_respond_to(h, :map)

    assert_raises(ArgumentError) { h.map = "foo" }
    assert_raises(ArgumentError) { h[:map] = "foo" }
    assert_raises(ArgumentError) { h['map'] = "foo" }
  end

  def test_05_enumerable
    h = create_sos
  end
end
