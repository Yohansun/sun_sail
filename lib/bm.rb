#encoding: utf-8
module Bm
  extend self
  #   Bm.benchmark("query all users") { User.all;'done' }
  #   => [query all users] (208.8 ms)
  #   Bm.benchmark("query all users",result: true) { User.all;'done' }
  #   => [query all users] done (3.1 ms)
  # Options:
  #   [:level] 
  #     logger level
  #   [:result]
  #     display result with block
  def benchmark(message = "Benchmarking", options = {})
    options[:level] ||= :info

    result = nil
    ms = Benchmark.ms { result = yield }

    result = case result
    when Hash   then result.collect {|k,v| "#{k}:#{v}"}.join(" ")
    when Array  then result.join(",")
    else result.to_s
    end

    message = if options[:result] == true
      '[%s] %s (%.1f ms)' % [ message,result, ms ]
    else
      '[%s] (%.1f ms)' % [ message, ms ]
    end

    logger.send(options[:level], message)
    result
  ensure
    logger.error(message << "\n" << $!.inspect << "\n" << $!.backtrace.join("\n")) if !$!.nil?
  end

  def logger
    @logger ||= Rails.logger
  end
end