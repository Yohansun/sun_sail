class TradeReport 
  include Mongoid::Document
  include Mongoid::Timestamps
  belongs_to :user
  field :conditions, type: Hash  
  field :export_name, type: String 
  field :user_id, type: Integer 

  def export_report
    TradeReporter.perform_async(self.id)
  end
end
