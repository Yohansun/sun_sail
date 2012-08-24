class TradeSource < ActiveRecord::Base
  attr_accessible :account_id, :app_key, :name, :secret_key, :session
end
