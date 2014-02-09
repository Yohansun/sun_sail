require 'spec_helper'

describe Account do
  before do
    Account.class_eval do
      def foo
        id
      end

      include CacheMethod
      cache_method :foo,hook: :after_commit
    end

    User.class_eval do
      def bar
        id
      end

      include CacheMethod
      cache_method :bar,class: Role,hook: :after_commit,foreign_key: :user_ids
    end
  end

  let(:account) { FactoryGirl.create(:account) }
  let(:role) { FactoryGirl.create(:role,account: account) }
  let(:user) { FactoryGirl.create(:user,roles: [role]) }

  context "Account" do
    it "should be cache" do
      account.foo
      Rails.cache.read("cache_method:Account/foo/#{account.id}").should == account.id
    end

    it "should be expires cache" do
      account.foo
      account.save
      Rails.cache.read("cache_method:Account/foo/#{account.id}").should be_nil
    end
  end

  context "User" do
    it 'should be cached User#bar' do
      user.bar
      Rails.cache.read("cache_method:User/bar/#{user.id}").should == user.id
    end

    it 'should be expires cache User#bar' do
      user.bar
      role.save
      Rails.cache.read("cache_method:User/bar/#{user.id}").should be_nil
    end
  end
end