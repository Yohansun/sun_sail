json.array!(@children) do |json, child|
	json.name child.name || child.fullname
	json.child_names child.children.map {|c| c.name}
end