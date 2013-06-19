module ControllerMacros
  
  def login_admin
    let(:current_account) { FactoryGirl.create(:account) }
    let(:current_user)    { FactoryGirl.create(:user,:username => "test",:password => "123456", account_ids: [current_account.id]) }
    
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:admin]
      sign_in current_user
    end
    
  end
end