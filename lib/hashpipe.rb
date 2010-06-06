module HashPipe
  #--
  # XXX we don't inherit from OpenStruct here because I'd have to play with its guts.
  #++
  class SuperOpenStruct
    def self.create_accessor(sym, obj)
      sym = sym.to_sym
      class << obj
        self
      end.class_eval { attr_accessor(sym) }
    end

    def self.callable_ivar(ivar)
      ivar.to_s.gsub(/^@/, '').to_sym
    end

    include Enumerable

    def initialize
      class << self
        def [](sym_or_str)
          self.class.create_accessor(sym_or_str, self) unless respond_to?(sym_or_str)
          self.send(sym_or_str)
        end

        def []=(sym_or_str, value)
          self.class.create_accessor(sym_or_str, self) unless respond_to?(sym_or_str)
          self.send("#{sym_or_str}=", value)
          self.send(sym_or_str)
        end

        def method_missing(sym, *args)
          newsym = sym.to_s.gsub(/=$/, '').to_sym
          if respond_to?(newsym) 
            raise ArgumentError, "this method is reserved"
          else
            self.class.create_accessor(newsym, self) 
            self.send(sym, *args)
          end
        end

        def keys
          instance_variables.map { |ivar| self.class.callable_ivar(ivar) } 
        end

        def values
          instance_variables.map { |ivar| self.send(self.class.callable_ivar(ivar)) }
        end

        def each
          instance_variables.each do |ivar|
            callable = self.class.callable_ivar(ivar)
            yield(callable, self.send(callable))
          end
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
