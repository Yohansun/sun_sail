# == Schema Information
#
# Table name: accounts
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  key        :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

require 'spec_helper'

describe Account do
  before do
    @current_account = create(:account)
  end
  context "judges if trade should auto preprocess right now" do
    it "should auto preprocess right now" do
      @current_account.settings.auto_settings = {"start_preprocess_at" => (Time.now - 1.hour).strftime("%H:%M:%S"), "end_preprocess_at" => (Time.now + 1.hour).strftime("%H:%M:%S")}
      @current_account.can_auto_preprocess_right_now.should be_true
    end

    it "should auto preprocess in 3600 seconds" do
      @current_account.settings.auto_settings = {"start_preprocess_at" => (Time.now + 1.hour).strftime("%H:%M:%S"), "end_preprocess_at" => (Time.now + 2.hour).strftime("%H:%M:%S")}
      @current_account.can_auto_preprocess_right_now.should equal(3600)
    end
  end

  context "judges if trade should auto dispatch right now" do
    it "should auto dispatch right now" do
      @current_account.settings.auto_settings = {"start_dispatch_at" => (Time.now - 1.hour).strftime("%H:%M:%S"), "end_dispatch_at" => (Time.now - 3.hour).strftime("%H:%M:%S")}
      @current_account.can_auto_dispatch_right_now.should be_true
    end

    it "should auto dispatch in 79200 seconds" do
      @current_account.settings.auto_settings = {"start_dispatch_at" => (Time.now - 2.hour).strftime("%H:%M:%S"), "end_dispatch_at" => (Time.now - 1.hour).strftime("%H:%M:%S")}
      @current_account.can_auto_dispatch_right_now.should equal(79200)
    end
  end

  context "judges if trade should auto deliver right now" do
    it "should auto deliver right now" do
      @current_account.settings.auto_settings = {}
      @current_account.can_auto_deliver_right_now.should be_true
    end

    it "should auto deliver in 3600 seconds" do
      @current_account.settings.auto_settings = {"start_deliver_at" => (Time.now + 1.hour).strftime("%H:%M:%S"), "end_deliver_at" => (Time.now - 1.hour).strftime("%H:%M:%S")}
      @current_account.can_auto_deliver_right_now.should equal(3600)
    end
  end
end