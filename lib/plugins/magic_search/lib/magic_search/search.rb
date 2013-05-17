require 'magic_search/group'
require 'magic_search/condition'
module MagicSearch
  module Search
    module ClassMethods
      include Group
      def search(searchs)
        condition = Condition.new(self,searchs)
        where(condition.to_condition)
      end
    end
  end
end