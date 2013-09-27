#encoding: utf-8
class Hash
  # {foo: 'bar'}.prefix_root('data.example')
  # => {"data"=>{"example"=>{:foo=>"bar"}}}
  def prefix_root(prefixes)
    roots = prefixes.split(/\./)
    roots[0..-2].inject(hash={}) { |k,v| k[v] = {}}[roots[-1]] = self
    hash
  end
end