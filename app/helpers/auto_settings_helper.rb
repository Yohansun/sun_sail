# -*- encoding:utf-8 -*-
module AutoSettingsHelper

  AutoBlocks = ['automerge','deliver','dispatch','preprocess','notify']

  def auto_block_with_text
    {
      'automerge'   => '自动合并订单',
      'deliver'     => '自动发货',
      'dispatch'    => '自动分派',
      'preprocess'  => '自动预处理',
      'notify'      => '自动提醒'
    }
  end

  def current_auto_block_text(action_name)
    auto_block_with_text.each do |block, block_text|
      return block_text if action_name =~ /#{block}/
    end
  end
end