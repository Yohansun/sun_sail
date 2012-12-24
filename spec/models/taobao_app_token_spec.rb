# == Schema Information
#
# Table name: taobao_app_tokens
#
#  id                            :integer(4)      not null, primary key
#  account_id                    :integer(4)
#  access_token                  :string(255)
#  taobao_user_id                :string(255)
#  taobao_user_nick              :string(255)
#  refresh_token                 :string(255)
#  created_at                    :datetime        not null
#  updated_at                    :datetime        not null
#  last_refresh_at               :datetime
#  trade_source_id               :integer(4)
#  refresh_token_last_refresh_at :datetime
#

require 'spec_helper'

describe TaobaoAppToken do
end