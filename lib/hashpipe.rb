require 'delegate'

module HashPipe
  #--
  # XXX we don't inherit from OpenStruct here because I'd have to play with its guts.
  #++
  class SuperOpenStruct

    def self.create_accessor(sym, obj)
      attr_accessor(sym)
    end

    # similar to ivar_coerce only doesn't use instance variables
    def [](sym_or_str)
      sym = sym_or_str.to_sym

      self.class.create_accessor(sym, self)
      self.send(sym)
    end

    def []=(sym_or_str, value)
      sym = sym_or_str.to_sym
      self.class.create_accessor(sym, self)
      self.send("#{sym}=", value)
      self.send(sym)
    end

    def method_missing(sym, *args)
      newsym = sym.to_s.gsub(/=$/, '').to_sym
      p newsym
      self.class.create_accessor(newsym, self)

      self.send(sym, *args)
    end

    def lock!
      def method_missing(*args)
        raise ArgumentError, "this openstruct is locked."
      end
    end
  end
end

if $0 == __FILE__
  h = HashPipe::SuperOpenStruct.new
  h.foo = "bar"
  h.bar = "baz"
  h.lock!
  p h[:bar]
  p h.foo
  p h.quux
end
