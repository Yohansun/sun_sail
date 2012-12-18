# == Schema Information
#
# Table name: bbs_topics
#
#  id              :integer(4)      not null, primary key
#  bbs_category_id :integer(4)
#  user_id         :integer(4)
#  title           :string(255)
#  read_count      :integer(4)      default(0)
#  download_count  :integer(4)      default(0)
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#
require 'spec_helper'

describe BbsTopic do
end