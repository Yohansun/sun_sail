require 'iconv'
class EncodeHandle < Faraday::Response::Middleware
  def call(env)
    @app.call(env).on_complete do |environment|
      env[:body] = Iconv.iconv("UTF-8//IGNORE","GB2312//IGNORE",env[:body])[0] if charset(env) == "gb2312"
    end
  end

  def charset(env)
    content_type = env[:response_headers].detect {|k,v| k =~ /content-type/i}
    if content_type[1] =~ /charset=([a-zA-Z0-9]*)/
      charset = $1
    end
    charset
  end
end
Faraday.register_middleware :response,:encode_handle => EncodeHandle