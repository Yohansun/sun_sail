require 'active_support/core_ext/object/blank'
class Object
  def or(other)
    blank? ? other : self
  end
end