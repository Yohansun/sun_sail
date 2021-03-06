module RequestMacros
  def login_admin
    let(:current_account) { FactoryGirl.create(:account) }
    let(:role) { create(:role,:account => current_account) }
    let(:current_user)    { FactoryGirl.create(:user,:username => "test",:password => "123456", accounts: [current_account],:roles => [role]) }

    before(:each) do
      current_account.settings[:wizard_step] = :finish
      current_user.superadmin!
      post user_session_path, :user => {:email => "test", :password => "123456" }
    end
  end
end