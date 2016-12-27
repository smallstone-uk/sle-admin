;(function($) {
	$.fn.htmlClick = function(a) {
		var caller = $(this);
		$(document).bind("mousedown.eventsGrp", function(event) {
			var target = $(event.target);
			if (!target.is(caller) && !target.is(caller.find('*')))
				if (typeof a == "function") a();
		});
	}
	
	$.popup = function(content, confirmation) {
		$('.popup_box, .dim').remove();
		$('body').prepend("<div class='dim'></div><div class='popup_box'>" + content + "</div>");
		
		var box = $('.popup_box');
		var dim = $('.dim');
		box.center();
		dim.fadeIn();
		
		box.css({
			"transform": "scale3d(1,1,1)",
			"opacity": 1
		});
	
		box.htmlClick(function() {
			if (typeof confirmation == "undefined" || !confirmation) {
				dim.remove();
				box.remove();
			}
		});
	}
	$.popup.close = function() {
		var box = $('.popup_box');
		var dim = $('.dim');
		dim.remove();
		box.remove();
	}
 
}(jQuery));