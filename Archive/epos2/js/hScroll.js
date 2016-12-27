;(function ($) {
	$.fn.enableHScroll = function() {
		function handler() {
			var lastPos = $(this).scrollLeft();
			$(this).on('scroll', function() {
				var newPos = $(this).scrollLeft();
				if (newPos !== lastPos) {
					$(this).trigger('scrollh', newPos - lastPos);
					lastPos = newPos;
				}
			});
		}
		return this.each(function() {
			var el = $(this);
			if (!el.data('hScrollEnabled')) {
				el.data('hScrollEnabled', true);                 
				handler.call(el);
			}
		});
	}
}(jQuery));
