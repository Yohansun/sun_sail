module CallcenterHelper
	def brief_info_contrast(start_at, end_at)

    map = %Q{
      function() {
        emit(this.user_id, {  
          reply_count: this.daily_reply_count, 
          inquired_count: this.daily_inquired_count,
          created_count: this.daily_created_count,
          created_payment: this.daily_created_payment,
          paid_count: this.daily_paid_count,
          paid_payment: this.daily_paid_payment
        });
      }
    }
    reduce = %Q{
      function(key, values) {
        var result = {
          reply_count: 0,
          inquired_count: 0,
          created_count: 0,
          created_payment: 0,
          paid_count: 0,
          paid_payment: 0
        };
        values.forEach(function(value) {
          result.reply_count += value.daily_reply_count
          result.inquired_count += value.daily_inquired_count
          result.created_count += value.daily_created_count
          result.created_payment += value.daily_created_payment
          result.paid_count += value.daily_paid_count
          result.paid_payment += value.daily_paid_payment
        });
        return result;
      }
    }

    contrast_info = WangwangMemberContrast.between(created_at: start_at..end_at).map_reduce(map, reduce).out(inline: true)
    #contrast_info = WangwangMemberContrast.between(created_at: ("2012-11-22").to_time(:local)..("2012-11-23").to_time(:local)).map_reduce(map, reduce).out(inline: true)
    p contrast_info
  end
end