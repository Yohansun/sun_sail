module CallcenterHelper
	def brief_info_contrast(start_at, end_at)
    map = %Q{
      function() {
        emit(this.user_id, {  
          daily_reply_count: this.daily_reply_count,
          daily_inquired_count: this.daily_inquired_count,
          daily_created_count: this.daily_created_count,
          daily_created_payment: this.daily_created_payment,
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
          daily_created_count: 0,
          daily_created_payment: 0,
          daily_paid_count: 0,
          daily_paid_payment: 0
        };
        values.forEach(function(value) {
          result.daily_reply_count += value.daily_reply_count
          result.daily_inquired_count += value.daily_inquired_count
          result.daily_created_count += value.daily_created_count
          result.daily_created_payment += value.daily_created_payment
          result.daily_paid_count += value.daily_paid_count
          result.daily_paid_payment += value.daily_paid_payment
        });
        return result;
      }
    }

    contrast_info = WangwangMemberContrast.between(created_at: start_at..end_at).map_reduce(map, reduce).out(inline: true)
    #contrast_info = WangwangMemberContrast.between(created_at: ("2012-11-22").to_time(:local)..("2012-11-23").to_time(:local)).map_reduce(map, reduce).out(inline: true)
    p contrast_info
  end

  def inquired_and_created_contrast(start_at, end_at)
    map = %Q{
      function() {
        emit(this.user_id, {
          daily_inquired_count: this.daily_inquired_count,
          daily_created_count: this.daily_created_count,
          daily_created_payment: this.daily_created_payment,
          two_days_lost_count: this.two_days_lost_count,
          two_days_created_count: this.two_days_created_count,
          two_days_created_payment: this.two_days_created_payment
        });
      }
    }
    reduce = %Q{
      function(key, values) {
        var result = {
          daily_inquired_count: 0,
          daily_created_count: 0,
          daily_created_payment: 0,
          two_days_lost_count: 0,
          two_days_created_count: 0,
          two_days_created_payment: 0
        };
        values.forEach(function(value) {
          result.daily_inquired_count += value.daily_inquired_count
          result.daily_created_count += value.daily_created_count
          result.daily_created_payment += value.daily_created_payment
          result.two_days_lost_count += value.two_days_lost_count
          result.two_days_created_count += value.two_days_created_count
          result.two_days_created_payment += value.two_days_created_payment
        });
        return result;
      }
    }

    contrast_info = WangwangMemberContrast.between(created_at: start_at..end_at).map_reduce(map, reduce).out(inline: true)
    p contrast_info
  end
end