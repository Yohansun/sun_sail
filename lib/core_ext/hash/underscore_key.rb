class Hash
  def underscore_key
    dup.underscore_key!
  end

  def underscore_key!
    keys.each do |key|
      if self[key].is_a?(Hash)
        self[key.to_s.underscore] = delete(key).underscore_key!
      elsif self[key].is_a?(Array)
        self[key.to_s.underscore] = delete(key).collect{|sub| sub.underscore_key!}
      else
        self[key.to_s.underscore] = delete(key)
      end
    end
    self
  end
end