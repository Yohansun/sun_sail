module BaseHelper
	def recursive_symbolize_keys! hash
    hash = hash.symbolize_keys
    hash.values.select{|v| v.is_a? Hash}.each{|h| recursive_symbolize_keys!(h)}
    hash
  end
end
