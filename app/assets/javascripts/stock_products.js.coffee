# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
#9 You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$('#product').change ()->
	$.get('/change_stock_product', {'product_id': $('#product').val()})
