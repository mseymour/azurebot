class Hash
  alias :oldIndexer :[]

  def [](val)
     if val.respond_to? :upcase then oldIndexer(val.upcase) else oldIndexer(val) end
  end

  alias :oldSetter :[]=
  def []=(key, value)
      if key.respond_to? :upcase then oldSetter(key.upcase, value) else oldSetter(key, value) end
  end
end