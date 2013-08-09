class Hash
  def underscore_key
    dup.underscore_key!
  end

  def underscore_key!
    keys.each do |key|
      self[key.underscore] = delete(key)
    end
    self
  end
end