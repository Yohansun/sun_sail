#encoding: utf-8
namespace :magic_order do
  task :setup do
    invoke_tasks
  end

  def env
    ENV['RAILS_ENV'] == "production" ? "production" : "development"
  end

  def invoke_tasks

    logger.formatter = proc do |severity, datetime, progname, msg|
      "#{datetime}: #{msg}\n"
    end

    task_count = task_names.length
    task_names.each_with_index do |task_name,index|
      next if invoked_task?(task_name)
      puts "[#{index+1}/#{task_count}](#{task_name})"
      task_name = task_name.gsub('/',':')
      Rake::Task[task_name].invoke
      logger.info "RAILS_ENV=#{env} rake #{task_name}"
    end
  end

  def task_names
    invoke_files.reject.collect {|path| path.gsub(/#{root}\/|\.rake/,'')}
  end

  def invoke_files
    Dir.glob("#{root}/magic_order/**").keep_if {|name| name.match(/\.rake$/)}
  end

  def invoked_task?(name)
    task_name = `grep -e "RAILS_ENV=#{env} rake #{name}$" #{logger_file}`.chomp
    task_name.present?
  end

  # lib/tasks
  def root
    File.expand_path("..",__FILE__)
  end

  def logger
    @logger ||= Logger.new(logger_file)
  end

  def logger_file
    root + "/setup.log"
  end
end