$(function() {
  var options = {
    data  : linkage_data
  }
  var sel = new LinkageSelect(options);
  sel.bind('.level_1','<%= @bill.op_state %>');
  sel.bind('.level_2','<%= @bill.op_city %>');
  sel.bind('.level_3','<%= @bill.op_district %>');
});

function validateStockBill(){
  var checked_input = $('input[name="bill_product_ids[]"]:checked');
  if(checked_input.length < 1){
    alert('请选择至少一个商品');
    event.preventDefault();
    }else{
      var checked_ids = checked_input.map(function(){ return this.value }).get().join(',');
      $('#bill_product_ids').val(checked_ids)
    }
};

function validateProductValues(){
  if($("#product_title").val() == ""){
    alert("请选择商品名称");
    event.preventDefault();
  }else if($("#product_number").val() == ""){
    alert("请输入商品数量");
    event.preventDefault();
  }else if($("#product_price").val() == ""){
    alert("请输入商品进货价");
    event.preventDefault();
  }else if($("#product_total_price").val() == ""){
    alert("请输入实际总价");
    event.preventDefault();
  }
};

function processRequest(bill){
  if($('input:checked').length < 1){
    alert('请选择一个进行操作');
  }else{
    var flag = true;
    if($(bill).attr("mesg")){
       flag = confirm($(bill).attr("mesg"));
    };
    var self_form = $(bill).closest("form");
    if(flag==true){                      
      self_form.attr({action: $(bill).attr("goto") ,method: $(bill).attr("request_method")});
      self_form.submit();
    }else{
      return false
    };   
  }
}