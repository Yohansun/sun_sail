class ChangeSellerCcEmailsToText < ActiveRecord::Migration
  def change
  	change_column :sellers, :email, :text 
  	change_column :sellers, :cc_emails, :text 
  end
end
