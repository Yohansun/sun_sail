# == Schema Information
#
# Table name: settings
#
#  id         :integer(4)      not null, primary key
#  var        :string(255)     not null
#  value      :text
#  thing_id   :integer(4)
#  thing_type :string(30)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class TradeSetting < RailsSettings::Settings
	attr_accessible :var
end
