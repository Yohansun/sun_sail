def test_bill_status(class_name, state_name)

  state_items = [
                  {
                    :state_name => :checked,
                    :method_name => :do_check,
                    :allow_status => [:created],
                    :unlocked => true,
                    :timestrap_name => "checked_at"
                  },
                  {
                    :state_name => :syncking,
                    :method_name => :do_syncking,
                    :allow_status => [:synck_failed, :checked, :canceld_ok],
                    :unlocked => true,
                    :timestrap_name => "sync_at"
                  },
                  {
                    :state_name => :syncked,
                    :method_name => :do_syncked,
                    :allow_status => [:syncking],
                    :timestrap_name => "sync_succeded_at"
                  },
                  {
                    :state_name => :synck_failed,
                    :method_name => :do_synck_fail,
                    :allow_status => [:syncking],
                    :timestrap_name => "sync_failed_at"
                  },
                  {
                    :state_name => :stocked,
                    :method_name => :do_stock,
                    :allow_status => [:created, :checked, :syncking, :syncked, :synck_failed, :stocked, :canceling, :canceld_ok, :canceld_failed],
                    :timestrap_name => "confirm_stocked_at"
                  },
                  {
                    :state_name => :closed,
                    :method_name => :do_close,
                    :allow_status => [:created, :checked, :synck_failed, :canceld_ok]
                  },
                  {
                    :state_name => :canceling,
                    :method_name => :do_canceling,
                    :allow_status => [:syncked],
                    :unlocked => true,
                    :timestrap_name => "canceled_at"
                  },
                  {
                    :state_name => :canceld_ok,
                    :method_name => :do_cancel_ok,
                    :allow_status => [:canceling],
                    :timestrap_name => "cancel_succeded_at"
                  },
                  {
                    :state_name => :canceld_failed,
                    :method_name => :do_cancel_fail,
                    :allow_status => [:canceling],
                    :timestrap_name => "cancel_failed_at"
                  }
                ]
  s_item = state_items.find{|s| s[:state_name] == state_name}
  if s_item.present?
    sta_name = s_item[:state_name]
    method_name = s_item[:method_name]
    allow_status = s_item[:allow_status]
    timestrap_name = s_item[:timestrap_name]
    only_activated = s_item.has_key?(:unlocked)

    [:none, :activated, :locked].each do |opt|
      [:created, :checked, :syncking, :syncked,
      :synck_failed, :stocked, :closed, :canceling,
      :canceld_ok, :canceld_failed].each do |s_name|
        is_can =  if allow_status.include?(s_name)
                    #是否只允许非锁定stock_bill执行change state
                    if only_activated && ![:activated, :none].include?(opt)
                      false
                    else
                      true
                    end
                  else
                    false
                  end
        if is_can
          change_stock_bill_status_success(class_name, opt, s_name, method_name, timestrap_name)
        else
          change_stock_bill_status_fail(class_name, opt, s_name, method_name, timestrap_name)
        end
      end
    end
  end
end

def change_stock_bill_status_success(class_name, opt_name, sta_name, method_name, timestrap_name)
  #find stock_bill
  stock_bill = FactoryGirl.create("#{opt_name}_#{sta_name}_#{class_name}")
  #验证stock_bill当前state
  stock_bill.state_name.should eql(sta_name)
  #验证stock_bill当前state时间戳
  if timestrap_name.present?
    stock_bill.send(timestrap_name).is_a?(NilClass).should be_true
  end
  #执行state_machine方法
  stock_bill.send(method_name).should be_true
  #验证stock_bill当前state时间戳(是时间类型)
  if timestrap_name.present?
    stock_bill.send(timestrap_name).is_a?(DateTime).should be_true
  end
end

def change_stock_bill_status_fail(class_name, opt_name, sta_name, method_name, timestrap_name)
  #find stock_bill
  stock_bill = FactoryGirl.create("#{opt_name}_#{sta_name}_#{class_name}")
  #验证stock_bill当前state
  stock_bill.state_name.should eql(sta_name)
  #验证stock_bill当前state时间戳
  if timestrap_name.present?
    stock_bill.send(timestrap_name).is_a?(NilClass).should be_true
  end
  #执行state_machine方法
  stock_bill.send(method_name).should_not be_true
  # #验证stock_bill当前state时间戳(nil)
  if timestrap_name.present?
    stock_bill.send(timestrap_name).is_a?(NilClass).should be_true
  end
end