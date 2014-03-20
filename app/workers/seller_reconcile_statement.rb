# -*- encoding : utf-8 -*-

class SellerReconcileStatement
  include Sidekiq::Worker
  sidekiq_options :queue => :seller_incomes_monthly, unique: true, unique_job_expiration: 120

  def perform
    account = Account.find_by_name("多乐士官方旗舰店")
    account.sellers.each do |seller|
      rs = ReconcileStatement.new(trade_store_source: '天猫店', trade_store_name: '多乐士旗舰店', seller_id: seller.id, account_id: account.id)
      rs.audit_time = Time.now
      begin
        rs.save!
      rescue ActiveRecord::RecordNotSaved => e
        rs.errors.full_messages
      end

      map = %Q{
        function() {
          for(var i in this.taobao_orders) {
            if(this.taobao_orders[i].outer_iid != null){
              emit(this.taobao_orders[i].outer_iid, {num: this.taobao_orders[i].num });
            }
          }
        }
      }

      ref_map = %Q{
        function() {
          for(var i in this.ref_batches) {
            if(this.ref_batches[i].status == 'return_ref_money' || this.ref_batches[i].status == 'confirm_return_money'){
              for(var j in this.ref_batches[i].ref_orders){
                emit(this.ref_batches[i].ref_orders[j].product_id, {num: this.ref_batches[i].ref_orders[j].num });
              }
            }
          }
        }
      }

      reduce = %Q{
        function(key, values) {
          var result = {num: 0};
          values.forEach(function(value) {
            result.num += value.num;
          });
          return result;
        }
      }

      trades = Trade.where(:end_time.gte => (rs.audit_time),
                           :end_time.lt => (rs.audit_time.end_of_month),
                           status: "TRADE_FINISHED",
                           seller_id: seller.id)

      refund_trades = Trade.where(
        :ref_batches.elem_match => {
          :status.in => ["confirm_return_money", "return_ref_money"],
          "ref_logs.operated_at" => {
            "$gte" => (rs.audit_time),
            "$lt"  => (rs.audit_time.end_of_month)
          }
        },
        status:    "TRADE_FINISHED",
        seller_id: seller.id
      )

      # map_reduce出所有taobao_order的商品外部编码
      reconcile_iids = trades.map_reduce(map, reduce).out(inline: true)

      # 添加map_reduce中已有的Iid对应的商品
      reconcile_iids.each do |iid|
        current_product = Product.find_by_outer_id(iid['_id'])
        if current_product
          current_product_detail = rs.product_details.find_by_outer_id(current_product.outer_id)
          if current_product_detail
            current_product_detail.initial_num += iid['value']['num'].to_i
            current_product_detail.total_num += iid['value']['num'].to_i
            current_product_detail.save
          else
            if rs.last_month_rs.present? && rs.last_month_rs.product_details.where(outer_id: current_product.outer_id).count > 0
              temp_last_month = rs.last_month_rs.product_details.where(outer_id: current_product.outer_id).first
              temp_last_month_num = temp_last_month.redefine_last_month_num + temp_last_month.initial_num - temp_last_month.subtraction
              temp_last_month_num >= 0 ? last_month_num = 0 : last_month_num = temp_last_month_num
            else
              last_month_num = 0
            end
            r_statement = ReconcileStatement.where(seller_id: seller.id, outer_id: current_product.outer_id)
            r_statement.length > 0 ? audit_price = r_statement.last.audit_price : audit_price = 0
            ReconcileProductDetail.create(reconcile_statement_id: rs.id,
                                          name: current_product.try(:name),
                                          product_id: current_product.id,
                                          outer_id: current_product.outer_id,
                                          initial_num: iid['value']['num'],
                                          last_month_num: last_month_num,
                                          subtraction: 0,
                                          audit_price: audit_price,
                                          seller_id: seller.id,
                                          sell_price: initial_num * audit_price,
                                          total_num: iid['value']['num'].to_i)
          end
        end
      end

      # 添加map_reduce中没有的Iid对应的商品
      Product.find_each do |product|
        if product.try(:good_type) == 1 && rs.product_details.where(outer_id: product.outer_id).count == 0
          if rs.last_month_rs.present? && rs.last_month_rs.product_details.where(outer_id: product.outer_id).count > 0
            temp_last_month = rs.last_month_rs.product_details.where(outer_id: product.outer_id).first
            temp_last_month_num = temp_last_month.redefine_last_month_num + temp_last_month.initial_num - temp_last_month.subtraction
            temp_last_month_num >= 0 ? last_month_num = 0 : last_month_num = temp_last_month_num
          else
            last_month_num = 0
          end
          r_statement = ReconcileStatement.where(seller_id: seller.id, outer_id: product.outer_id)
          r_statement.length > 0 ? audit_price = r_statement.last.audit_price : audit_price = 0
          ReconcileProductDetail.create(reconcile_statement_id: rs.id,
                                        name: product.try(:name),
                                        product_id: product.id,
                                        outer_id: product.outer_id,
                                        initial_num: 0,
                                        last_month_num: last_month_num,
                                        subtraction: 0,
                                        audit_price: audit_price,
                                        seller_id: seller.id,
                                        sell_price: initial_num * audit_price,
                                        total_num: 0)
        end
      end

      # map_reduce出所有交易成功线下退货,线下退款的商品
      return_product_ids = refund_trades.map_reduce(ref_map, reduce).out(inline: true)
      # 计算线下退货, 线下退款数量
      ref_details = ReconcileStatement.find(rs.id).product_details
      return_product_ids.each do |ref|
        ref_details.where(product_id: ref['_id']).first.update_attributes!(offline_return: ref['value']['num'].to_i)
      end

      # 计算每个商品的最终数量
      adapted_rs = ReconcileStatement.find(rs.id)
      adapted_rs.product_details.each do |detail|
        detail.total_num = (detail.total_num + detail.redefine_last_month_num - detail.subtraction - detail.offline_return)
        detail.save!
      end
    end

  end

end