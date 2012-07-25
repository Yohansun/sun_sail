class AddCcEmailsToSellers < ActiveRecord::Migration
  def change
    add_column :sellers, :cc_emails, :string
  end
end
