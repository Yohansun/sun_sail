class JingdongCategory < SimpleDelegator
  def initialize(obj)
    validation(obj)
    @attrs = attrs(obj)
    @auth_attrs = obj.account.jingdong_query_conditions
    super
  end
  
  def query
    
  end
  
  def attvalue_names
    values.collect {|u| u["name"]}
  end
  
  # 类目属性信息   京东API无法通过 @attrs 取 属性名称
  # def property(cid)
  #   @attnames ||= JingdongQuery.get({method:"360buy.ware.get.attribute",fields: property_columns,cid: cid},@auth_attrs)
  # end

  # 类目属性值信息
  def values
    @attvalues ||= JingdongQuery.get({method:"360buy.ware.get.attvalue",fields: values_columns,avs: @attrs},@auth_attrs)["category_attribute_value_response"]["att_values"]
  end

  def default_attribute
    @default_attribute ||= "attribute_s"
  end
  
  def default_attribute=(var)
    @default_attribute = var
    validation(self)
    @attrs = attrs(self)
    @attvalues = nil
  end
  
  def attrs(obj)
    obj.send(default_attribute).gsub(/\^|\||\,/,';')
  end
  
  private
  # def property_columns
  #   "aid,name,cid"
  # end
  
  def values_columns
    "aid,name,vid"
  end
  
  def validation(obj)
    raise NoMethodError,": undefined method `#{default_attribute}' for #{obj.inspect}" unless obj.respond_to?(default_attribute)
    raise NoMethodError,": undefined method `account' for #{obj.inspect}" unless obj.respond_to?(:account) && obj.account.is_a?(Account)
  end
end