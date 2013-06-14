#encoding: utf-8
require 'minitest'
require 'minitest/autorun'
require 'magic_enum'
require 'active_model'

class TestMagicEnum < Minitest::Test
  
  class Foo
    include MagicEnum
    attr_accessor :status
    enum_attr :status, [["Open",1],["Close",2],["Reopen",3],["Done","D"]]
  end
  
  class Bar
    include ActiveModel::Validations
    include MagicEnum
    attr_accessor :status,:published
    enum_attr :status, [["Open",1],["Close",2],["Reopen",3],["Done","D"]]
    enum_attr :published,[["公开",1],["私人",2]],:not_valid => true
  end
  
  def setup
    @foo = Foo.new
    @bar = Bar.new
  end
  
  def test_enum_attr
    assert_equal [["Open",1],["Close",2],["Reopen",3],["Done","D"]],Foo::STATUS
  end
  
  def test_enum_values
    assert_equal [1,2,3,"D"],Foo::STATUS_VALUES
    @foo.status = 1
    assert_equal true, @foo.status_1?
    assert_equal false, @foo.status_2?
    @foo.status = "D"
    assert_equal true, @foo.status_d?
  end
  
  def test_enum_name
    assert_equal nil,@foo.status_name
    @foo.status = 2
    assert_equal "Close", @foo.status_name
  end
  
  def test_validate
    assert_equal false, @bar.valid?
    
    assert_equal ["Status is not included in the list"], @bar.errors.full_messages
    
    @bar.status = 0
    assert_equal false, @bar.valid?
    assert_equal ["Status is not included in the list"], @bar.errors.full_messages
    
    @bar.status = 1
    assert_equal true, @bar.valid?
    assert_equal [], @bar.errors.full_messages
  end

  def test_not_validate
    @bar.status = 1
    assert_equal true,@bar.valid?
    assert_equal nil,@bar.published_name
  end
end