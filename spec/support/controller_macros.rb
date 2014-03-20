module ControllerMacros

  def login_admin
    let(:current_account) { FactoryGirl.create(:account) }
    let(:role) { create(:role,:account => current_account) }
    let(:current_user)    { FactoryGirl.create(:user, accounts: [current_account], roles: [role]) }

    before(:each) do
      current_account.settings[:wizard_step] = :finish
      current_user.superadmin!
      @request.env["devise.mapping"] = Devise.mappings[:admin]
      sign_in current_user
    end
  end

  def taobao_authed
    let(:current_account) { FactoryGirl.create(:account) }
    before(:each) do
      @request.session[:account_id] = current_account.id
      set_current_account(current_account)
    end
  end
end