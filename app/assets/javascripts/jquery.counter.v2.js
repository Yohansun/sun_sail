/*
 * jQuery.counter.js for jQuery
 * Author : Mos luck Chang
 * Email : chunhang@networking.io
 * Date : 2012.10.24 16:00
 */
;(function($){
	$.fn.counter = function(configs){
		var	obj = {
			starts : configs.starts ? configs.starts.getTime() : 0,
			deadline : configs.deadline ? configs.deadline.getTime() : 0,
			calc : function(value){
				var ret = {
					day : Math.floor(value/(1000*60*60*24)),
					hour : Math.floor(value/(1000*60*60)%24),
					minute : Math.floor(value/(1000*60)%60),
					second : Math.floor(value/(1000)%60)
				};
				for(var i in ret){
					ret[i] = (ret[i] < 10 ? '0' : '') + ret[i];
				}
				return ret;
			},
			count : function(){
				var arr = [],
				now = +new Date();
				if((obj.starts != 0 && now < obj.starts) || (obj.deadline != 0 && now > obj.deadline)){
					return;
				}
				arr = obj.calc(configs.deadline - now);
				if(arr.day *1 == 0){
					$('#day_text').hide();
				} else {
					configs.day.html(arr.day);
				}
				configs.timer.html(arr.hour + ':' + arr.minute + ':' + arr.second);
				setTimeout(arguments.callee,1000);
			}
		};
		obj.count();
	}
})(jQuery);