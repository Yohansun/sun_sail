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
