class OperationLog
  include Mongoid::Document
  include Mongoid::Timestamps

  field :operation,      type: String
  field :operated_at,    type: DateTime
  field :operator,       type: String
  field :operator_id,    type: Integer

  embedded_in :trades
  after_create :transfer_to_redis

  def account_id
    trades.account_id
  end  

  def transfer_to_redis
  	if operator_id.present?
  	  user = User.find operator_id
      if user.present?
    	  operationlog = "#{Time.now.to_i},#{operation},#{operated_at},#{operator},#{user.roles.map{|role| role.role_s}}, #{self._parent.tid}"
    	  if user.has_role?(:seller)
          $redis.ZREMRANGEBYRANK("account:#{account_id}:OperationLogToSeller", 0,-2001)
    	  	$redis.ZADD("account:#{account_id}:OperationLogToSeller", 1, operationlog)
    	  end

    	  if user.has_role?(:cs)
          $redis.ZREMRANGEBYRANK("account:#{account_id}:OperationLogToCs", 0,-2001)
    	  	$redis.ZADD("account:#{account_id}:OperationLogToCs", 1, operationlog)
    	  end

    	  if user.has_role?(:admin)
          $redis.ZREMRANGEBYRANK("account:#{account_id}:OperationLogToAdmin", 0,-2001)
    	  	$redis.ZADD("account:#{account_id}:OperationLogToAdmin", 1, operationlog)

    	  end
        $redis.ZREMRANGEBYRANK("account:#{account_id}:OperationLogToAll", 0,-2001)
    	  $redis.ZADD("account:#{account_id}:OperationLogToAll", 1, operationlog)
      end
  	end
  end
end
