class Array
  alias_method :orig_delete, :delete
  def delete(e=nil,&block)
    if block_given?
      e = find(&block)
    end
    orig_delete(e)
  end
end