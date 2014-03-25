$(function(){
  var split_order = $('#ord_split');//modal box id
  var origin_order = $('#ord_origin');
  var ord_actual = $('#ord_actual');
  var ord_total = $('#ord_total');
  var ord_favourable = $('#ord_favourable');
  var ord_freight = $('#ord_freight');

  //add
  split_order.on('click','.js-split_add', function(index){
    var parent = $(this).parent();

    var ord_split = $("#split_templete");

    parent.before(ord_split=$(ord_split.html()));

    ord_split.find('.split_sum').on('sumChange',function(){
      var parent = $(this).parents('td')
      var num1 = parseInt(parent.find('.ord_total').val() || 0)
      var num2 = parseInt(parent.find('.ord_favourable').val() || 0)
      var num3 = parseInt(parent.find('.ord_freight').val() || 0)
      $(this).text(num1 - num2 + num3)
    });

    origin_order.find('td[id ^= "item-name"]').map(function(){
      // return this.innerText
      return $('<option value="' + this.id + '">' + this.innerText + '</option>')
    }).each(function(i, option){
      ord_split.find('.item_options').append(option)
    });

    ord_split.find('.ord_total').chaifen({
      str: 'ord_total'
    });
    ord_split.find('.ord_freight').chaifen({
      str: 'ord_freight'
    });
    ord_split.find('.ord_favourable').chaifen({
      str: 'ord_favourable'
    });


  });

  //add split item
  split_order.on('click','.js-add_split_item', function(e){
    e.preventDefault();
    var that = $(this);
    var input = that.siblings('.js-split_itemnum');
    var input_val = input.val();
    var item_body = that.parents('.ord_split').find('tbody');
    var option = that.siblings('select').find(':checked');
    var option_val = option.val()
    var option_text = option.text();

    var relArr = item_body.find('[data-rel]').map(function(){
      return $(this).data('rel')
    }).get()

    var rel_index = $.inArray(option_val, relArr)

    if (input_val && rel_index == -1) {

      var id_item = $('#' + option_val).siblings('.item-number');
      var id_total = id_item.text();

      if(input_val >= id_total){
        input_val = id_total
      }
      id_item.text(id_total - input_val);

      var tr = $(
        '<tr>' +
          '<td class="text-left title" data-rel="' + option_val + '">' + option_text + '</td>' +
          '<td class="item-number">'+ input_val + '</td>' +
          '<td><a class="js-remove_split_item" href="javascript:;">删除</a></td>' +
        '</tr>'
        )
      if(input_val) item_body.prepend(tr);

    } else if(input_val) {
      alert('已经添加该商品，请删除后再添加！')
    }
    input.val('');
  });
  //remove item
  split_order.on('click','.js-remove_split_item', function(){

    var tr = $(this).parents('tr');
    var del_id = tr.find('td').first().data('rel');
    var del_num = +tr.find('.item-number').text();

    var td = $('#' + del_id).siblings('.item-number');
    var td_num = parseInt(td.text()) + del_num
    td.text(td_num)

    $(this).parents('tr').remove();
  });

  //cancel split
  split_order.on('click','.js-remove_split', function(){
    var ord_actual = $('#ord_actual')
    var ord_total = $('#ord_total')
    var ord_favourable = $('#ord_favourable')
    var ord_freight = $('#ord_freight')

    var parent = $(this).parent()
    parent.find('.js-remove_split_item').click()

    var num1 = parseInt(parent.find('.ord_total').val() || 0)
    var num2 = parseInt(parent.find('.ord_favourable').val() || 0)
    var num3 = parseInt(parent.find('.ord_freight').val() || 0)

    ord_total.text(parseInt(ord_total.text()) + num1)
    ord_favourable.text(parseInt(ord_favourable.text()) + num2)
    ord_freight.text(parseInt(ord_freight.text()) + num3)

    $('#ord_actual').trigger('numChange')

    parent.remove();

  });

  //edit number
  split_order.on('click keyup','.js-split_itemnum',function(){

    var current_item = $(this).siblings('select').find(':selected').val();
    var current_item_num = parseInt($('#' + current_item).siblings('.item-number').text());
    var edit_number = parseInt($(this).val());

    $(this).attr('max',current_item_num);

    if (edit_number <= current_item_num && edit_number > 0) {
      return edit_number;
    }else{
      $(this).val('');
    };
  });

  $('#ord_actual').live('numChange', function(){
    var ord_actual = $('#ord_actual');
    var ord_total = $('#ord_total');
    var ord_favourable = $('#ord_favourable');
    var ord_freight = $('#ord_freight');
    ord_actual.text( parseInt(ord_total.text()) + parseInt(ord_favourable.text()) + parseInt(ord_freight.text()) )
  })


  $.fn.chaifen = function(option){

    function Chaifen(ele){
      this.input = $(ele)
      this.str = option.str
      this.topEle =  $('#' + option.str)
      this.arrSum = 0
      this.total = this.topEle.data('num')
      this.init()
    }

    Chaifen.prototype = {

      init: function(){
        var that = this

        this.input.on('blur', function(e){
          var value = +this.value
          if(isNaN(value)) {
            this.value = 0

            that.arrSum = that.addArr()

            that.topEle.text(that.total - that.arrSum)

            return $('#ord_actual').trigger('numChange')
          }

          that.calc.call(that, this, value)
        })
      },
      calc: function(input, value){

        var total = this.total
        var topTotal = +this.topEle.text()

        this.arrSum = this.addArr()

        if(this.arrSum >= total){

          this.arrOtherSum = this.addOtherArr(input)

          input.value = total - this.arrOtherSum

        }
        this.arrSum = this.addArr()

        this.topEle.text(total - this.arrSum)

        $('#ord_actual').trigger('numChange')

        $('.split_sum').trigger('sumChange')
      },
      plus: function(){
        var num = 0;
        for(var i = 0; i < arguments.length; i ++){
          num += +arguments[i]
        }
        return num
      },
      addArr: function(){
        return this.addArrayMap( $('.' + this.str) )
      },
      addOtherArr: function(input){
        var parents = $(input).parents('.ord_split')
        return this.addArrayMap( parents.siblings().find('.' + this.str) )
      },
      addArrayMap: function(ele){
        var now = ele.map(function(){
          return this.value
        }).get()
        return this.plus.apply(this, now)
      }

    }

    return this.each(function(){
      return new Chaifen(this)
    })
  }
});