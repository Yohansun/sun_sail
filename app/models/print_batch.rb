# -*- encoding : utf-8 -*-

class PrintBatch
  include Mongoid::Document
  include Mongoid::Timestamps

  field :batch_num,      type: Integer

  embedded_in :deliver_bills

end