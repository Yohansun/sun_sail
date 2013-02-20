$(function(){
	//timepicker
	$('.timepickers').timeEntry({
	    show24Hours: true,
	    showSeconds: true,
	    spinnerImage: 'images/spinnerUpDown.png',
	    spinnerSize: [17, 26, 0],
	    spinnerIncDecOnly: true
	});
//select2
	$(".select2").select2();//待解决：如果统一用一个class的话select的默认值会不显示
	$('.multmail').select2({tags:["example@doorder.com"],placeholder: "example@doorder.com",width: "220px"})
//advance btn
	$('.js-open_advance').click(function(){
		$('.search_advanced').fadeToggle();
		$(this).parent()
			.toggleClass('open_advance');
		$(this).children('i')
			.toggleClass('icon-arrow-up')
	})
	$('.js-remove_unit_item').click(function(){
		$(this).parent('.unit_item').remove()
	})
	$('tr').hover(function(){
		$(this).find('.js-btns_show').toggle()
	})
//operate button in tr
	$('#js-table tr:gt(0)').mouseover(function(){
		$('tr .btn-group').hide()
		$(this).find('.btn-group').css({'position':'absolute'}).show();
	});
//options-checkbox show or hide
	var $first_tr_checkbox = $('#js-table tr:first').find(':checkbox');
	$first_tr_checkbox.click(function(){
		$first_tr_checkbox.parents('#js-table').find(':checkbox').prop('checked',$first_tr_checkbox.prop('checked'))
	});
});

//datepicker
$(document).on('focus', '.datepickers', function (e) {
	$(this).datepicker({
		format: 'yyyy-mm-dd'
	});
});
