module CallcenterHelper
	def brief_info_contrast(start_at, end_at)
    map = %Q{
      function() {
        emit(this.user_id, {  
          daily_reply_count: this.daily_reply_count,
          daily_inquired_count: this.daily_inquired_count,
          yesterday_created_count: this.yesterday_created_count,
          yesterday_created_payment: this.yesterday_created_payment,
          daily_paid_count: this.daily_paid_count,
          daily_paid_payment: this.daily_paid_payment
        });
      }
    }
    reduce = %Q{
      function(key, values) {
        var result = {
          daily_reply_count: 0,
          daily_inquired_count: 0,
          yesterday_created_count: 0,
          yesterday_created_payment: 0,
          daily_paid_count: 0,
          daily_paid_payment: 0
        };
        values.forEach(function(value) {
          result.daily_reply_count += value.daily_reply_count
          result.daily_inquired_count += value.daily_inquired_count
          result.yesterday_created_count += value.yesterday_created_count
          result.yesterday_created_payment += value.yesterday_created_payment
          result.daily_paid_count += value.daily_paid_count
          result.daily_paid_payment += value.daily_paid_payment
        });
        return result;
      }
    }

    contrast_info = WangwangMemberContrast.between(created_at: start_at..end_at).map_reduce(map, reduce).out(inline: true)
    #contrast_info = WangwangMemberContrast.between(created_at: ("2012-11-22").to_time(:local)..("2012-11-23").to_time(:local)).map_reduce(map, reduce).out(inline: true)
#    p contrast_info
  end

  def inquired_and_created_contrast(start_at, end_at)
    map = %Q{
      function() {
        emit(this.user_id, {
          daily_inquired_count: this.daily_inquired_count,
          daily_created_count: this.daily_created_count,
          daily_created_payment: this.daily_created_payment,
          tomorrow_lost_count: this.tomorrow_lost_count,
          tomorrow_created_count: this.tomorrow_created_count,
          tomorrow_created_payment: this.tomorrow_created_payment
        });
      }
    }
    reduce = %Q{
      function(key, values) {
        var result = {
          daily_inquired_count: 0,
          daily_created_count: 0,
          daily_created_payment: 0,
          tomorrow_lost_count: 0,
          tomorrow_created_count: 0,
          tomorrow_created_payment: 0
        };
        values.forEach(function(value) {
          result.daily_inquired_count += value.daily_inquired_count
          result.daily_created_count += value.daily_created_count
          result.daily_created_payment += value.daily_created_payment
          result.tomorrow_lost_count += value.tomorrow_lost_count
          result.tomorrow_created_count += value.tomorrow_created_count
          result.tomorrow_created_payment += value.tomorrow_created_payment
        });
        return result;
      }
    }

    contrast_info = WangwangMemberContrast.between(created_at: start_at..end_at).map_reduce(map, reduce).out(inline: true)
#    p contrast_info
  end

  def created_and_paid_contrast(start_at, end_at)
    map = %Q{
      function() {
        emit(this.user_id, {
          yesterday_created_count: this.yesterday_created_count,
          yesterday_created_payment: this.yesterday_created_payment,
          yesterday_lost_count: this.yesterday_lost_count,
          yesterday_lost_payment: this.yesterday_lost_payment,
          yesterday_paid_count: this.yesterday_paid_count,
          yesterday_paid_payment: this.yesterday_paid_payment,
          yesterday_final_paid_count: this.yesterday_final_paid_count,
          yesterday_final_paid_payment: this.yesterday_final_paid_payment
        });
      }
    }
    reduce = %Q{
      function(key, values) {
        var result = {
          yesterday_created_count: 0,
          yesterday_created_payment: 0,
          yesterday_lost_count: 0,
          yesterday_lost_payment: 0,
          yesterday_paid_count: 0,
          yesterday_paid_payment: 0,
          yesterday_final_paid_count: 0,
          yesterday_final_paid_payment: 0
        };
        values.forEach(function(value) {
          result.yesterday_created_count += value.yesterday_created_count
          result.yesterday_created_payment += value.yesterday_created_payment
          result.yesterday_lost_count += value.yesterday_lost_count
          result.yesterday_lost_payment += value.yesterday_lost_payment
          result.yesterday_paid_count += value.yesterday_paid_count
          result.yesterday_paid_payment += value.yesterday_paid_payment
          result.yesterday_final_paid_count += value.yesterday_final_paid_count
          result.yesterday_final_paid_payment += value.yesterday_final_paid_payment
        });
        return result;
      }
    }

    contrast_info = WangwangMemberContrast.between(created_at: start_at..end_at).map_reduce(map, reduce).out(inline: true)
#    p contrast_info
  end

  def followed_paid_contrast(start_at, end_at)
    map = %Q{
      function() {
        emit(this.user_id, {
          daily_paid_count: this.daily_paid_count,
          daily_paid_payment: this.daily_paid_payment,
          daily_quiet_paid_count: this.daily_quiet_paid_count,
          daily_quiet_paid_payment: this.daily_quiet_paid_payment,
          daily_self_paid_count: this.daily_self_paid_count,
          daily_self_paid_payment: this.daily_self_paid_payment,
          daily_others_paid_count: this.daily_others_paid_count,
          daily_others_paid_payment: this.daily_others_paid_payment
        });
      }
    }
    reduce = %Q{
      function(key, values) {
        var result = {
          daily_paid_count: 0,
          daily_paid_payment: 0,
          daily_quiet_paid_count: 0,
          daily_quiet_paid_payment: 0,
          daily_self_paid_count: 0,
          daily_self_paid_payment: 0,
          daily_others_paid_count: 0,
          daily_others_paid_payment: 0
        };
        values.forEach(function(value) {
          result.daily_paid_count += value.daily_paid_count
          result.daily_paid_payment += value.daily_paid_payment
          result.daily_quiet_paid_count += value.daily_quiet_paid_count
          result.daily_quiet_paid_payment += value.daily_quiet_paid_payment
          result.daily_self_paid_count += value.daily_self_paid_count
          result.daily_self_paid_payment += value.daily_self_paid_payment
          result.daily_others_paid_count += value.daily_others_paid_count
          result.daily_others_paid_payment += value.daily_others_paid_payment
        });
        return result;
      }
    }

    contrast_info = WangwangMemberContrast.between(created_at: start_at..end_at).map_reduce(map, reduce).out(inline: true)
#    p contrast_info
  end
end