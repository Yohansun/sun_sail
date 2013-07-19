# Loads the core plugins located in lib/plugins
require 'core_ext/object/blank'
Dir.glob(File.join(Rails.root, "lib/plugins/*")).sort.each do |directory|
  if File.directory?(directory)
    lib = File.join(directory, "lib")
    if File.directory?(lib)
      $:.unshift lib
      ActiveSupport::Dependencies.autoload_paths += [lib]
    end
    initializer = File.join(directory, "init.rb")
    if File.file?(initializer)
      config = MagicOrders::Application.config
      eval(File.read(initializer), binding, initializer)
    end
  end
end
