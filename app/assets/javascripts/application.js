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
//
//= require .//magic_orders
//
//= require_tree ../templates/
//= require_tree .//models
//= require_tree .//collections
//= require_tree .//views
//= require_tree .//routers
//= require_tree .

// 地区管理中区域自动补全
$(function () {
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
});
