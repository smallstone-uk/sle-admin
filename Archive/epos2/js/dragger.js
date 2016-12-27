(function($) {
	'use strict';
	
	var ACTIVE_CLASS = 'touchscroll-active';
	
	var touchScroll = function(element) {
		this.el = element;
		this.$el = $(element);
		this._initElements();
		return this;
	}
	
	touchScroll.DATA_KEY = 'touchscroll';
	touchScroll.DEFAULTS = {
		y: true,
		x: true
	};
	
	touchScroll.prototype._initElements = function() {
		this.$el.addClass(ACTIVE_CLASS);

		this.velocity = 0;
		this.velocityY = 0;

		$(document)
			.mouseup($.proxy(this._resetMouse, this))
			.click($.proxy(this._resetMouse, this));

		//this._initEvents();
	};
	
	$.touchScroll = touchScroll;
	
	$.fn.touchScroll = function(params) {
		return this.each(function() {
			var $this = $(this);
			var instance = $this.data(touchScroll.DATA_KEY);
			var options = $.extend({}, touchScroll.DEFAULTS, $this.data(), typeof params === 'object' && params);
			$this.data(touchScroll.DATA_KEY, (instance = new touchScroll(this, options)));
			console.log(instance);
		});
	}
}(window.jQuery));