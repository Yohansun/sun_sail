# == Schema Information
#
# Table name: logistic_groups
#
#  id           :integer(4)      not null, primary key
#  account_id   :integer(4)
#  name         :string(255)
#  split_number :integer(4)
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#

class LogisticGroup < ActiveRecord::Base
  attr_accessible :account_id, :name, :split_number

  belongs_to :account
  has_many :products

  validates :name, presence: true, uniqueness: { scope: :account_id}
  validates :split_number, numericality: true, presence: true

end
