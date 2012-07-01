require 'taobao_fu'

require 'yaml'
YAML::ENGINE.yamler = 'syck'

config_file = File.join(Rails.root, "config", "taobao.yml")
TaobaoFu.load(config_file) if FileTest::exists?(config_file)