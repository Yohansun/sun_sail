class ApiLogger < Grape::Middleware::Base

  def before
    logger.info "Started #{request_method} \"#{path_info}\" for #{ip} at #{Time.now}\n" +
    "Parameters: #{query_string}\n"
  end

  private

  def request_method
    env['REQUEST_METHOD']
  end

  def path_info
    env['PATH_INFO']
  end

  def query_string
    env["rack.request.form_hash"]
  end

  def ip
    request.ip
  end

  def logger
    @logger ||= MagicOrder::API.logger(Logger.new(Rails.root + "log/api.log"))
  end
 
end