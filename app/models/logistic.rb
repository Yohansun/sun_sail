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
#  account_id :integer(4)
#

# -*- encoding : utf-8 -*-
class Logistic < ActiveRecord::Base
  mount_uploader :xml, LogisticXmlUploader
  attr_accessible :name, :code, :xml

  belongs_to :account
  has_many :logistic_areas
  has_many :areas, through: :logistic_areas ,:dependent => :destroy
  has_many :users
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :code

  def self.three_mostly_used

    map = %Q{
      function() {
        if(this.logistic_id != null){
        emit(this.logistic_id, {num: 1});
        }
      }
    }

    reduce = %Q{
      function(key, values) {
        var result = {num: 0};
        values.forEach(function(value) {
          result.num += value.num;
        });
        return result;
      }
    }

    map_reduce_info = Trade.between(created: (Time.now - 3.months)..Time.now).ne(logistic_id: nil).map_reduce(map, reduce).out(inline: true).sort{|a, b| b['value']['num'] <=> a['value']['num']}
    ids = [].tap do |id|
      map_reduce_info.each_with_index do |info, i|
        id << info["_id"].to_i if i <= 2
      end
    end
    ids
  end

end
