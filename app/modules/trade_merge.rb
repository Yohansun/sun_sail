  # 合并订单
  module TradeMerge

    def self.included(base)
      base.extend(ClassMethods)
      base.class_eval do
        after_create :trig_auto_merge
        after_update :trig_auto_merge
      end
    end


    module ClassMethods


      def merge_trades trades

        # check first
        return false if check_can_merge(trades) == 0

        # if merging a merged trade1,
        # extract be merged trades from trade1.merged_trade_ids
        # flattern them with other trades in 1 level
        # finally destroy the merged trade1
        t_trades = []
        merged_trades = []
        trades.each{|t|
          if t.is_merged?
            ts = Trade.find t.merged_trade_ids
            ts.each{|tt|
              t_trades << tt
            }
            merged_trades << t
          else
            t_trades << t
          end
        }

        trades = t_trades


        # clone a new trade, for common informations
        first_trade = trades.last
        clone_attributes = [
          :account_id,
          :buyer_nick,
          :receiver_name,
          :receiver_mobile,
          :receiver_phone,
          :receiver_state,
          :receiver_city,
          :receiver_district,
          :receiver_zip,
          :receiver_address,
          :status,
          :created,
          :pay_time,
        ]
        new_trade = Trade.new
        clone_attributes.each{|a| new_trade[a] = first_trade[a]}
        # init attributes default value
        new_trade.seller_memo = ""
        new_trade.cs_memo = ""
        new_trade.gift_memo = ""
        new_trade.buyer_message = ""
        new_trade.total_fee = 0
        new_trade.payment = 0
        new_trade.promotion_fee = 0
        new_trade.taobao_orders = []
        new_trade.promotion_details = []
        new_trade.unusual_states = []
        new_trade.ref_batches = []
        new_trade.trade_gifts = []
        new_trade.merged_trade_ids = []

        # merge other attributes like products, price
        trades.each{|trade|
          # merge array attributes
          trade.taobao_orders.each{|order|
            same_order = new_trade.taobao_orders.to_a.find{|o|
              o.sku_id == order.sku_id && o.outer_iid == order.outer_iid && o.num_iid == order.num_iid
            }
            if same_order
              same_order.num += order.num
              same_order.cs_memo ||=  ""
              same_order.cs_memo += order.cs_memo.to_s + "\n" if order.cs_memo
            else
              new_trade.taobao_orders << order
            end
          }
          trade.promotion_details.each{|p| new_trade.promotion_details << p}
          trade.unusual_states.each{|p| new_trade.unusual_states << p}
          trade.ref_batches.each{|p| new_trade.ref_batches << p}
          trade.trade_gifts.each{|p| new_trade.trade_gifts << p}

          # merge values
          new_trade.seller_memo += trade.seller_memo.to_s+"\n" if trade.seller_memo
          new_trade.cs_memo += trade.cs_memo.to_s+"\n" if trade.seller_memo
          new_trade.gift_memo += trade.gift_memo.to_s+"\n" if trade.gift_memo
          new_trade.buyer_message += trade.buyer_message.to_s+"\n" if trade.buyer_message
          new_trade.promotion_fee += trade.promotion_fee if trade.promotion_fee
          new_trade.total_fee += trade.total_fee if trade.total_fee
          new_trade.payment += trade.payment if trade.payment

          new_trade.merged_trade_ids << trade.id
        }

        # create tid
        new_trade.tid = ("HB"+Time.now.to_i.to_s + new_trade.account_id.to_s + rand(10..99).to_s)

        # save
        new_trade.save!

        # update merged trades with new trade id
        trades.each{|trade| trade.update_attributes(merged_by_trade_id: new_trade.id)}

        merged_trades.each{|trade| trade.destroy}


        new_trade

      end

      def mark_mergable_trades trades
        merge_id = trades.last.id
        trades.each{|trade|
          #TODO: mark trades as mergable manually
          trade.mergeable_id = merge_id
          trade.save!
        }
        nil
      end

      # check if a list of trades can merge to 1 trade
      #   RETURN : 0  can not merge,  1 can auto merge, 2 can merge manually
      def check_can_merge trades

        can_not_merge = 0
        can_auto_merge = 1
        can_manually_merge = 2

        return can_not_merge if trades.size < 2
        return can_not_merge if ! trades.map(&:merged_by_trade_id).compact.blank?

        account = Account.find trades.first.account_id
        enabled, interval, start_at, end_at = account.settings.auto_settings.values_at "auto_merge",
          "auto_merge_pay_time_interval","auto_merge_start_at","auto_merge_end_at"
        interval = interval.to_i


        can = true
        first = trades.first
        # check first status pay status and dispatched status
        return can_not_merge if first.status != "WAIT_SELLER_SEND_GOODS" || first.dispatched_at?

        # check these attributes are same value
        check_attributes = [
          :account_id,
          :buyer_nick,
          :receiver_name,
          :receiver_mobile,
          :receiver_phone,
          :receiver_state,
          :receiver_city,
          :receiver_district,
          :receiver_zip,
          :receiver_address,
          :status,
          :dispatched_at, # should be nil
        ]
        trades[1..-1].each{|t|
          check_attributes.each{|attr|
            if t[attr] != first[attr]
              can = false
              break
            end
          }
          break if !can
        }

        return can_not_merge if !can

        first_time, latest_time = trades.map(&:pay_time).sort.values_at(0,-1)

        enabled = {1=>true, 0=>false}[enabled] || false


        # if trades pay time in a setted time(like 15.min)
        if  first_time+interval.minutes > latest_time &&
            (start_at.blank? || Time.now > Time.parse(start_at)) &&
            (end_at.blank? || Time.now < Time.parse(end_at)) &&
            enabled

          return can_auto_merge
        else
          return can_manually_merge
        end

      end


    end # end ClassMethods


    # check status change when create or update a trade
    def trig_auto_merge
      if !self.is_merged? && self.dispatched_at.blank? && self.status == "WAIT_SELLER_SEND_GOODS" &&
          (new_record? || status_changed?)
        self.auto_merge_trades
      end
    end



    def is_merged?
      !self.merged_trade_ids.blank?
    end

    def is_be_merged?
      !self.merged_by_trade_id.blank?
    end

    def mergeable_trades
      Trade.paid_undispatched.where({
          id:{"$ne"=>self.id},account_id:self.account_id,:merged_by_trade_id=>nil,
          :buyer_nick=>self.buyer_nick,
          :receiver_name=>self.receiver_name,
          :receiver_mobile=>self.receiver_mobile,
          :receiver_phone=>self.receiver_phone,
          :receiver_state=>self.receiver_state,
          :receiver_city=>self.receiver_city,
          :receiver_district=>self.receiver_district,
          :receiver_zip=>self.receiver_zip,
          :receiver_address=>self.receiver_address,
        })
    end

    # trigged when a trade status into PAID but UNDISPATCHED
    def auto_merge_trades(force=false)
      trades = mergeable_trades + [self]
      merge_status = Trade.check_can_merge trades
      case merge_status
      when 0
      when 1
        return Trade.merge_trades trades
      when 2
        if force
          return Trade.merge_trades trades
        else
          Trade.mark_mergable_trades trades
        end
      end

      return merge_status
    end


    def mark_mergable_trades
      trades = mergeable_trades + [self]
      Trade.mark_mergable_trades trades
    end


    # split a merged trade
    #  NOTICE: split will DESTROY the merged trade
    def split
      return false if !self.is_merged? || self.status != "WAIT_SELLER_SEND_GOODS" || self.dispatched_at.present?
      ts = Trade.find self.merged_trade_ids
      ts.each{|t|
        t.update_attributes(merged_by_trade_id:nil)
      }
      self.destroy

      # reset all
      ts.first.mark_mergable_trades

      ts
    end
  end
