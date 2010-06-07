require 'helper'

class TestHashpipeSuperOpenStruct < Test::Unit::TestCase
  def test_01_construct
    h = create_sos
    assert(h)
    assert_kind_of(HashPipe, h)
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
    h2 = create_sos
    h = create_sos

    h.foo = "bar"
    h.lock!

    assert_raises(NoMethodError) do
      h.bar = "baz"
    end

    assert_equal(h.foo,    "bar")
    assert_equal(h[:foo],  "bar")
    assert_equal(h['foo'], "bar")

    # should not raise
    h2.bar = "baz"
    h2.bar = "baz"

    assert_equal(h2.bar,    "baz")
    assert_equal(h2[:bar],  "baz")
    assert_equal(h2['bar'], "baz")
  end

  def test_04_overwrite
    h = create_sos
    assert_respond_to(h, :map)

    assert_raises(ArgumentError) { h.map = "foo" }
    assert_raises(ArgumentError) { h[:map] = "foo" }
    assert_raises(ArgumentError) { h['map'] = "foo" }
  end
  
  def test_05_keys_values
    h = create_sos
    h.foo = "bar"
    h.bar = "quux"

    assert_equal(
      h.keys.sort_by { |x| x.to_s }, 
      [:bar, :foo]
    )

    assert_equal(
      h.values.sort_by { |x| x.to_s }, 
      ["bar", "quux"]
    )
  end

  def test_06_enumerable
    h = create_sos
    assert_respond_to(h, :map)

    h[:foo] = "bar"
    h.bar   = :foo

    assert_equal(
      h.map { |k,v| [k,v] }.sort_by { |r| r[0].to_s }, 
      [[:bar, :foo], [:foo, "bar"]]
    )
  end
end
