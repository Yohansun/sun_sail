require 'spec_helper'

describe TradesController do

##### 显示所有订单 #####
  describe "GET #index" do
  end

##### 显示订单相关操作 #####
  describe "GET #show" do
  end

##### 显示订单预处理页面 #####
  describe "GET #edit" do
  end

##### 更新订单 #####
  describe "PUT #update" do
  end

##### 导出报表 #####
  describe "GET #export" do
  end

##### 批量确认发货 #####
  describe "GET #batch_check_goods" do
  end

##### 导出报表操作－按搜索条件导出 #####
  describe "GET #export" do
  end

##### 导出报表操作－按勾选订单导出 #####
  describe "GET #batch_export" do
  end

##### 批量添加赠品 #####
  describe "GET #batch_add_gift" do
  end

##### 验证批量添加赠品 #####
  describe "GET #verify_add_gift" do
  end

##### 设置交易完成 #####
  describe "GET #trade_finished" do
  end

##### 锁定订单 #####
  describe "GET #lock_trade" do
  end

##### 激活已锁定订单 #####
  describe "GET #activate_trade" do
  end

##### 淘宝订单匹配经销商 #####
  describe "GET #seller_for_area" do
  end

##### 其他来源订单匹配经销商 #####
  describe "GET #estimate_dispatch" do
  end

##### 批量发货 #####
  describe "GET #batch_deliver" do
  end

## 话说这个玩意应该放到users_controller里吧？！
##### 设置给用户分派订单的比例 #####
  describe "GET #assign_percent" do
  end

##### 设置自动开发票 #####
  describe "GET #change_invoice_setting" do
  end

##### 订单合并 #####
  describe "GET #merge" do
  end

##### 合并订单拆分 #####
  describe "GET #split" do
  end

##### 分拣单搜索 #####
  describe "GET #sort_product_search" do
  end

##### 属性备注匹配入库单 #####
  describe "GET #match_icp_bills" do
  end

##### 订单预处理－处理异常 #####
  describe "GET #solve_unusual_state" do
  end

end
