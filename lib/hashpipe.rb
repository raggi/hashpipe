class HashPipe
  def self.create_accessor(sym, obj)
    unless obj.__respond_to?(sym)
      class << obj; self; end.attr_accessor(sym)
    end
  end

  if :foo.respond_to?(:[]) # ruby1.9 optimization
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

  alias __class__ class unless defined?(__class__) # rbx has it.
  alias __instance_variables__ instance_variables
  alias __respond_to? respond_to?
  instance_methods.each { |m| undef_method m unless m =~ /^__|\?$/ }

  include Enumerable

  def [](sym_or_str)
    self.__class__.create_accessor(sym_or_str, self)
    self.__send__(sym_or_str)
  end

  def []=(sym_or_str, value)
    self.__class__.create_accessor(sym_or_str, self)
    self.__send__(:"#{sym_or_str}=", value)
  end

  def method_missing(sym, *args)
    newsym = sym.to_s.gsub(/=$/, '').to_sym
    if __respond_to?(newsym)
      raise ArgumentError, "this method is reserved"
    else
      self.__class__.create_accessor(newsym, self) 
      self.__send__(sym, *args)
    end
  end

  def keys
    __instance_variables__.map { |ivar| self.__class__.callable_ivar(ivar) } 
  end

  def values
    __instance_variables__.map { |ivar|
      self.__send__(self.__class__.callable_ivar(ivar))
    }
  end

  def each
    __instance_variables__.each do |ivar|
      callable = self.__class__.callable_ivar(ivar)
      yield(callable, self.__send__(callable))
    end
  end

  def lock!
    class << self; undef_method :method_missing; end
  end
end