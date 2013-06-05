require 'minitest'
require 'minitest/autorun'
require 'magic_enum'
require 'active_model'

class TestMagicEnum < Minitest::Test
  
  class Foo
    include MagicEnum
    attr_accessor :status
    enum_attr :status, [["Open",1],["Close",2],["Reopen",3]]
  end
  
  class Bar
    include ActiveModel::Validations
    include MagicEnum
    attr_accessor :status
    enum_attr :status, [["Open",1],["Close",2],["Reopen",3]]
  end
  
  def setup
    @foo = Foo.new
    @bar = Bar.new
  end
  
  def test_enum_attr
    assert_equal [["Open",1],["Close",2],["Reopen",3]],Foo::STATUS
  end
  
  def test_enum_values
    assert_equal [1,2,3],Foo::STATUS_VALUES
  end
  
  def test_enum_name
    assert_equal nil,@foo.status_name
    @foo.status = 2
    assert_equal "Close", @foo.status_name
  end
  
  def test_validate
    assert_equal false, @bar.valid?
    
    assert_equal ["Status can't be blank", "Status is not included in the list"], @bar.errors.full_messages
    
    @bar.status = 0
    assert_equal false, @bar.valid?
    assert_equal ["Status is not included in the list"], @bar.errors.full_messages
    
    @bar.status = 1
    assert_equal true, @bar.valid?
    assert_equal [], @bar.errors.full_messages
  end
end