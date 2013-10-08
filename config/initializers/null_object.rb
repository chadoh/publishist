class NullObject
  def method_missing(*args)
    self
  end
end
