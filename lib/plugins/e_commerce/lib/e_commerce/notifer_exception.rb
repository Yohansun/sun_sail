#encoding: utf-8
module ECommerce
  module NotiferException
    def handle_exception(options={},&block)
      begin
        yield
      rescue Exception => e
        result = options.delete(:result)
        BacktraceMailer.background_exception_notification(e,{data: options})
        result
      end
    end
  end
end