// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require swfobjects
//= require underscore
//= require underscore.string
//= require backbone
//= require bootstrap-datepicker
//
//= require .//magic_orders
//
//= require_tree ../templates/
//= require_tree .//models
//= require_tree .//collections
//= require_tree .//views
//= require_tree .//routers
//= require_tree .

_.mixin(_.str.exports());

$(function () {
  // fire dashboard icons
  if ($(".centerDashboard").length > 0) {
    $("body").addClass("yellow_background");

    $('.centerDashboard a').hide();
    $(".centerDashboard").show();
    $(".centerDashboard div").mouseenter(function(event){
      $(this).css('height','142px');
      $(this).delay(1000).stop(true).animate({'top':'-20px'},10)
      .animate({'top':'0'},100)
      .animate({'top':'-15px'},100)
      .animate({'top':'0'},200);
    });

    $(window).load(function(){
      dashboardFadeIn();
    });
  };

  //高级搜索显示/隐藏
  $('#advanced_btn').click(function(){
    $('#advanced_btn i').toggleClass('icon-arrow-up');
    $(this).parents('fieldset').siblings('div.fieldset_group').toggle();
  })
  //input多选框全选和全不选
  $('#checkbox_all').click(function(){
    var $this = $(this);
    $('td input:checkbox').attr('checked',!!$this.attr('checked'))
  })

  $("#area_parent_id").tokenInput("/areas/autocomplete.json",{
  	crossDomain: false,
  	tokenLimit: 1,
  	theme: "facebook",
  	noResultsText: "无对应地区!"
  });

  $("#area_search").tokenInput("/areas/autocomplete.json",{
  	crossDomain: false,
  	theme: "facebook",
  	noResultsText: "无对应地区!"
  });

  $('.navbar .dropdown-menu a').click(function(){
    $('.navbar .dropdown.open .dropdown-toggle').dropdown('toggle');
  });

  $('.goto_stock').click(function(){
    $('#storage_pop .open_stock').attr('href', "/sellers/" + $(this).data('id') + "/change_stock_type")
  });

  $('.login_acount').click(function(argument) {
    var seller_id = $(this).attr('data-id');
    $("#seller_id_container").html(seller_id);
    $.get("/sellers/seller_user", {seller_id:seller_id}, function(result){
    });
  })

   $('.area_management').click(function(argument) {
     var seller_id = $(this).attr('data-id');
     $.get("/sellers/seller_area", {seller_id:seller_id}, function(result){
     });
   })

   $('.logistic_area').click(function(argument) {
     var logistic_id = $(this).attr('data-id');
     $.get("/logistics/logistic_area", {logistic_id:logistic_id}, function(result){
     });
   })

   $('.logistic_login_acount').click(function(argument) {
    var logistic_id = $(this).attr('data-id');
    $("#logistic_id_container").html(logistic_id);
    $.get("/logistics/logistic_user", {logistic_id:logistic_id}, function(result){
    });
  })

  $('#logistic_select').change(function(){
    xml = $(this).val()
    console.log(xml)
    bind_swf(MagicOrders.idCarrier, 'kdd', xml)
  })
});

function blocktheui () {
  $.blockUI({
    message: '<h1>loading...</h1>',
    css: {
      border: 'none',
      padding: '15px',
      backgroundColor: '#000',
      '-webkit-border-radius': '10px',
      '-moz-border-radius': '10px',
      opacity: .5,
      color: '#fff'
    }
  });
}

function dashboardFadeIn() {
  $('.centerDashboard a').each(function(i, el){
    $(el).delay(300 * i).fadeIn(300);
  });
}

jsReady = false
var dd

function isReady() { // //flash 会调用此方法检测页面 js 是否已经准备完毕；
  return jsReady
}

function pageInit() {   //flash 会检测页面 js 是否已经准备完毕；  
  jsReady = true       //flash 需要这个值；  
}

function printfeedback(str){  //如果flash 数据还未载入成功，会返回一个报错信息在str中；
  MagicOrders.hasPrint = true
}

function printfeedbacksize(str){ // 如果页面端需要知道 flash 当前的真实高度，这里会返回一个 ［宽，高］ 数组；
  alert(str);
}

function startPrint() {
  dd = getElement('logistic_print')
  dd.startPrint(); //调用Flash 的打印命令 
  MagicOrders.hasPrint = true
}

function getElement(id){ //获取Flash 元素，尽量别用jquery ，以jquery返回的是一个 jquery对象，而不是flash 本身 ；
  return document.getElementById(id);
}

function bind_deliver_swf (id) {
  bind_swf(id, 'ffd')
}

function bind_logistic_swf (id, xml) {
  var flashvars = {
    'config': '/trades/print_deliver_bill.xml?ids='+ id,
    'ppHeight': '349',
    'ppWidth': '648',
    'template': 'default',
    'printType': 'kdd',
    'displayprint': 'false',            //是否显示打印按钮
    'view': 'true',                   //是否需要打印预览
    'allowScriptAccess': 'always',
    'needfeedbacksize': 'false'
  }

  if(xml == ''){
    $.get('/trades/'+id+'/logistic_info', {}, function(data){
      flashvars.templateUrl = data
      swfobject.embedSWF("/swf/deliver_bill.swf", "logistic_print", "550", "300", "9.0.0","/swf/expressInstall.swf", flashvars);
    })
  }else{
    flashvars.templateUrl = xml
    swfobject.embedSWF("/swf/deliver_bill.swf", "logistic_print", "550", "300", "9.0.0","/swf/expressInstall.swf", flashvars);
  }
}

function bind_swf(id, type, xml) {
  var flashvars = {
    'config': '/trades/print_deliver_bill.xml?ids=' + id.toString(),
    'ppHeight': '349',
    'ppWidth': '648',
    'template': 'default',
    'printType': type,
    'displayprint': 'true',            //是否显示打印按钮
    'view': 'false',                   //是否需要打印预览
    'allowScriptAccess': 'always',
    'needfeedbacksize': 'false'
  }

  if(type == 'kdd'){
    flashvars.templateUrl = xml
  }

  swfobject.embedSWF("/swf/deliver_bill.swf", "showbox", "83", "35", "9.0.0","/swf/expressInstall.swf", flashvars);
}
