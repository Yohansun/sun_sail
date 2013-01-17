# -*- encoding : utf-8 -*-
class AddBbsCategoryContent < ActiveRecord::Migration
  def change
  	BbsCategory.create :name => "资料下载"
  	BbsCategory.create :name => "最新新闻"
  end
end
