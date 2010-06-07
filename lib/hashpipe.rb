class HashPipe
  def self.create_accessor(sym, obj)
    class << obj; self; end.attr_accessor(sym)
  end

  if :foo.respond_to?(:[]) # ruby1.9
    def self.callable_ivar(ivar)
      ivar[/^@?(.*)$/, 1].to_sym
    end
  else
    def self.callable_ivar(ivar)
      ivar.to_s[/^@?(.*)$/, 1].to_sym
    end
  end

  class << self
    public :attr_accessor
  end

  include Enumerable

  def [](sym_or_str)
    self.class.create_accessor(sym_or_str, self) unless respond_to?(sym_or_str)
    self.__send__(sym_or_str)
  end

  def []=(sym_or_str, value)
    self.class.create_accessor(sym_or_str, self) unless respond_to?(sym_or_str)
    self.__send__(:"#{sym_or_str}=", value)
  end

  def method_missing(sym, *args)
    newsym = sym.to_s.gsub(/=$/, '').to_sym
    if respond_to?(newsym) 
      raise ArgumentError, "this method is reserved"
    else
      self.class.create_accessor(newsym, self) 
      self.__send__(sym, *args)
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
      yield(callable, self.__send__(callable))
    end
  end

  def lock!
    class << self; undef_method :method_missing; end
  end
end