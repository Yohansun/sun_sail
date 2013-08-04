#encoding: utf-8
## 代码异常跟踪
# 当程序中代码不是按照预期执行的可使用 +BacktraceMailer.background_exception_notification(@exception)+
# example:
#     def perform
#       begin
#         ...
#         self.save!
#         ...
#       rescue Exception => e
#         BacktraceMailer.background_exception_notification(e)
#         raise e
#       end
#     end

require 'exception_notifier'
class BacktraceMailer < ExceptionNotifier::Notifier
  self.mailer_name = 'exception_notifier'

  class << self
    def default_sender_address
      %("Exception Notifier" <exception.notifier@networking.io>)
    end

    def default_exception_recipients
      %w(zhoubin@networking.io wang@networking.io hui@networking.io xiaoliang@networking.io zhanghong@networking.io)
    end

    def default_sections
      ["backtrace"]
    end
  end

  def background_exception_notification(exception, options={})
    self.append_view_path "#{Rails.root}/app/views"

    @options   = self.class.default_options
    @exception = exception
    @backtrace = exception.backtrace || []
    @sections  = @options[:background_sections]
    @data      = options[:data] || {}

    @data.each do |name, value|
      instance_variable_set("@#{name}", value)
    end
    subject  = compose_subject(exception)

    mail(:to => @options[:exception_recipients], :from => @options[:sender_address], :subject => subject) do |format|
      format.text { render "#{mailer_name}/background_exception_notification" }
    end.deliver
  end

end