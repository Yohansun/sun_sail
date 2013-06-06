## Welcome to MagicEnum

MagicEnum is a usefule helper tools.

Learn to use a quick way to look at the following:

        class Foo
          include MagicEnum
          attr_accessor :status
          # If not have include ActiveModel::Validations
          include ActiveModel::Validations  # will be automatic verification.
          enum_attr :status,[["Open",1],["Close",2],["ReOpen",3],["Done","D"]]
        end
        
        @foo = Foo.new
        @foo.valid?           # => false
        @foo.errors.messages  #=> {:status=>["can't be blank", "is not included in the list"]}
        @foo.status = 1
        @foo.status_name      # => "Open"
        @foo.status_1?        # => true
        @foo.status = "D"
        @foo.status_d?        # => true
        Foo::STATUS           # => [["Open",1],["Close",2],["ReOpen",3],["Done","D"]]