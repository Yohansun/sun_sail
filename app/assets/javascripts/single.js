$(function(){

	//timepicker
	$('.timepickers').timeEntry({
	    show24Hours: true,
	    showSeconds: true,
	    spinnerImage: '/assets/spinnerUpDown.png',
	    spinnerSize: [17, 26, 0],
	    spinnerIncDecOnly: true
	});

	//tab.js
	$('.js-nav_tabs a:first').tab('show');
	/*$('a[data-toggle="tab"]').on('shown', function (e) {

	})*/
	$('.subnav').affix();

	if($('.js-datetimepicker').length > 0){
		$('.js-datetimepicker').datetimepicker({
			language:  'zh-CN',
			weekStart: 1,
			todayBtn:  1,
			autoclose: 1,
			todayHighlight: 1,
			startView: 2,
			forceParse: 0,
			showMeridian: 1
		});
	}

//select2
	$('.select2').select2();
	$('.multmail').select2({tags:["example@doorder.com"],placeholder: "example@doorder.com",width: "220px"});
	$('.select2_stock').select2();
//linkage select
	// var linkage_options	= {
	// 	data	: data
	// }

	// var sel = new LinkageSelect(linkage_options);
	// sel.bind('.linkage_select .js-linkage_1','1');
	// sel.bind('.linkage_select .js-linkage_1');
	// sel.bind('.linkage_select .js-linkage_1');

//modal
	$('.js-modal').modal({show:false});
//advance btn
	// $('.js-affix').affix();
	//affix position
	function form_height (){
		var form_height = $('.js-affix').outerHeight();
		$('.btn-toolbar').css('top',form_height + 71 + 'px');
	};
	form_height();
	$('.js-add').click(function(){
		$('.item_group').append('<span class="unit_item pull-left"><label class="help-inline">所有所有订单订单</label><button class="js-remove_unit_item" value=""> x </button></span>')
		form_height();
	});
	$(window).resize(function(){
		form_height();
	});
	//advance open
	// $('.js-open_advance').click(function(){
	// 	$(this).parents('fieldset').siblings('.search_advanced').toggle(0,function(){
	// 		form_height()
	// 	});
	// 	$(this).parent()
	// 		.toggleClass('open_advance');
	// 	$(this).children('i')
	// 		.toggleClass('icon-arrow-up');
	// })
	$('.js-remove_unit_item').click(function(){
		$(this).parent('.unit_item').remove()
	})
	$('tr').hover(function(){
		$(this).find('.js-btns_show').toggle()
	})
//operate button in tr
	$('.js-table tr:gt(0)').mouseover(function(){
		$('.js-table tr .btn-group').hide()
		$(this).find('.btn-group').css({'position':'absolute'}).show();
	});
//options-checkbox show or hide
	var $first_tr_checkbox = $('.js-table tr:first').find(':checkbox');
	$first_tr_checkbox.click(function(){
		$first_tr_checkbox.parents('.js-table').find(':checkbox').prop('checked',$first_tr_checkbox.prop('checked'))
	});
});
