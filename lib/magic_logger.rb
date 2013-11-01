#encoding: utf-8
require 'logger'
class MagicLogger < ::Logger
  def initialize(*args)
    super
    @formatter = LoggerFormatter.new
  end

  class LoggerFormatter < ::Logger::Formatter
    def call(severity, datetime, progname, msg)
      "[#{datetime}] #{severity} #{String === msg ? msg : msg.inspect}\n"
    end
  end
end