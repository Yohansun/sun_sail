# -*- encoding : utf-8 -*-
class DelayAutoDispatch
  include Sidekiq::Worker
  sidekiq_options :queue => :auto_process, unique: true, unique_job_expiration: 120 #自动分派队列

  def perform(id)
    trade = Trade.where(_id: id).first or return

    #异常订单不自动分派
    return if trade.has_unusual_state

    trade.auto_dispatch!
  end
end