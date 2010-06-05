module HashPipe
  #--
  # XXX we don't inherit from OpenStruct here because I'd have to play with its guts.
  #++
  class SuperOpenStruct
    def self.create_accessor(sym, obj)
      sym = sym.to_sym

      unless obj.respond_to?(sym)
        class << obj
          self
        end.class_eval { attr_accessor(sym) }
      end
    end

    def initialize
      class << self
        def [](sym_or_str)
          self.class.create_accessor(sym_or_str, self)
          self.send(sym_or_str)
        end

        def []=(sym_or_str, value)
          self.class.create_accessor(sym_or_str, self)
          self.send("#{sym_or_str}=", value)
          self.send(sym_or_str)
        end

        def method_missing(sym, *args)
          newsym = sym.to_s.gsub(/=$/, '').to_sym
          self.class.create_accessor(newsym, self)
          self.send(sym, *args)
        end

        def lock!
          class << self
            def method_missing(*args)
              raise ArgumentError, "this openstruct is locked."
            end
          end
        end
      end
    end
  end
end

if $0 == __FILE__
  h = HashPipe::SuperOpenStruct.new
  h.foo = "bar"
  h.bar = "baz"
  h.lock!
  p h['bar']
  p h[:bar]
  p h.foo
  p h.quux = "bar"

  h2 = HashPipe::SuperOpenStruct.new
  h2.quux = "quux"
  p h2.quux
end
