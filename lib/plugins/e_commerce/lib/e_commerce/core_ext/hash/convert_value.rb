class Hash
  def convert_values(&block)
    each {|k,v| self[k] = yield k,v }
  end
end