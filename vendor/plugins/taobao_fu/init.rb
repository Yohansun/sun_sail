require "taobao_fu"

#Fix "couldn't parse YAML" error ruby 1.9.2/rails 3.1
require 'yaml'
YAML::ENGINE.yamler= 'syck' if defined?(YAML::ENGINE)

config_file = File.join(Rails.root, "config", "taobao.yml")
TaobaoFu.load(config_file) if FileTest::exists?(config_file)
