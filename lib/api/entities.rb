module MagicOrder
  module Entities
    class RefundProduct < Grape::Entity
      root "refund_products","refund_product"

      expose :status

      expose :errors, :if => lambda {|object,options| object.errors.present? }
    end
  end
end