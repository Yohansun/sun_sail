# == Schema Information
#
# Table name: logistics
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  options    :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#  code       :string(255)     default("OTHER")
#  xml        :string(255)
#
require 'spec_helper'

describe Logistic do
end


