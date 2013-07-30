#encoding: utf-8
module ECommerce
  module Generators
    class SynchronizationGenerator < Rails::Generators::NamedBase

      source_root File.expand_path("../templates", __FILE__)

      desc "创建一个新的需要同步的电子商务同步接口"

      def create_synchronization_files
        template 'module.rb', File.join('app/models', class_path, "#{file_name}_sync.rb")
      end
    end
  end
end