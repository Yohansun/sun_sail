# == Schema Information
#
# Table name: sellers
#
#  id                :integer(4)      not null, primary key
#  name              :string(255)
#  fullname          :string(255)
#  address           :string(255)
#  mobile            :string(255)
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#  parent_id         :integer(4)
#  lft               :integer(4)
#  rgt               :integer(4)
#  children_count    :integer(4)      default(0)
#  email             :string(255)
#  telephone         :string(255)
#  cc_emails         :string(255)
#  user_id           :integer(4)
#  pinyin            :string(255)
#  active            :boolean(1)      default(TRUE)
#  performance_score :integer(4)      default(0)
#  interface         :string(255)
#  has_stock         :boolean(1)      default(FALSE)
#  stock_opened_at   :datetime
#

require 'spec_helper'

describe Seller do
end