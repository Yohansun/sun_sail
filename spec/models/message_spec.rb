#encoding: utf-8
require 'spec_helper'

describe Message do
  let(:dulux)   {FactoryGirl.create(:account,:name => "dulux",:key => "dulux")}
  
  before(:each) do
    @message = Message.new
    @message.save
  end
  
  it "Test validations" do
    @message.errors.messages.should == {:send_type=>["不能为空", "不包含于列表中"], :recipients=>["不能为空"], :account_id=>["不能为空"], :title=>["不能为空"], :content=>["不能为空"]}
    
    @message.update_attributes(:send_type => "sms",:recipients => "abc,123",:account_id => 1, :title => "test", :content => "...")
    @message.errors.messages.should == {:recipients=>["电话号码只能是数字"]}
    
    @message.update_attributes(:send_type => "mail",:recipients => "abc,zhoubin@networking.io",:account_id => 1, :title => "test", :content => "...")
    @message.errors.messages.should == {:recipients=>["邮件格式不正确"]}
    
    @message.update_attributes(:send_type => "mail",:recipients => "abc@abc.com,zhoubin@networking.io",:account_id => 1, :title => "test", :content => "...")
    @message.should be_valid
    
    @message.update_attributes(:send_type => "sms",:recipients => "15848792001,18370242287",:account_id => dulux.id, :title => "test", :content => "...")
    @message.should be_valid
  end
end
