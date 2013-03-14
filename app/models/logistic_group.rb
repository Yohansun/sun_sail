class LogisticGroup < ActiveRecord::Base
  attr_accessible :account_id, :name, :split_number

  belongs_to :account

  validates :name, presence: true, uniqueness: { scope: :account_id}
  validates :split_number, numericality: true, presence: true

end
