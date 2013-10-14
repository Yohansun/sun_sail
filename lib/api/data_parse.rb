#encoding: utf-8
Dir["#{Rails.root}/lib/api/fields_alias/*.rb"].each {|file| require file}

class DataParse
  FORMATER = %w(xml json)
  attr_reader :third_party_name
  def initialize(env,name)
    @env = env
    @third_party_name = name
  end

  def env
    @env
  end

  def before
    @datas = if xml?
      Hash.from_xml(params["xml"])
    elsif json?
      JSON.parse params["json"]
    else
      {}
    end
  end

  def parse
    before
    standard_output(@datas)
  end

  def standard_output(hash)
    if FieldsAlias::Fields.api?(method_id)
      parameters = parsed_date(hash)
      return parameters.is_a?(Hash) ? parameters : {}
    end
    {}
  end

  def parsed_date(hash)
    #查找第三方名称
    klass = FieldsAlias::third_part(third_party_name,method_id).new hash
    klass.formater
  end

  def xml?
    params.key?("xml")
  end

  def json?
    params.key?("json")
  end

  def params
    env["rack.request.form_hash"]
  end

  def method_id
    params["method"]
  end
end