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

$(function () {
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

  $(".navbar .nav .areas").on("click", function (event) {
      event.preventDefault();
      Backbone.history.navigate('areas', true);
  });
  $(".navbar .nav .trades").on("click", function (event) {
      event.preventDefault();
      Backbone.history.navigate('trades', true);
  });
  $(".navbar .nav .sellers").on("click", function (event) {
      event.preventDefault();
      Backbone.history.navigate('sellers', true);
  });
  $(".navbar .nav .users").on("click", function (event) {
      event.preventDefault();
      Backbone.history.navigate('users', true);
  });
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