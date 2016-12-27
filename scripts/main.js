;(function($) {
	var request = {
		url: window.location.protocol + "//" + window.location.hostname + "/",
		protocol: window.location.protocol,
		hostname: window.location.hostname
	};
	
	var global = {
		lb_progress: 0
	};
	
	/////////////////////////////////////////////////////////////////////////////

	closeModal = function() {
		$('.modal-screen').remove();
	}

	modal = function(url, args, callback) {
		args = args || {};
		callback = callback || function() {};

		$.ajax({
		    type: 'POST',
		    url: url,
		    data: args,
		    success: function(data) {
		    	$('.modal-screen').remove();

		    	$('body').prepend(
	    			'<div class="modal-screen">\
	    			<div class="modal-dialog">\
	    			<div class="modal-wrapper">\
	    			' + data + '\
	    			</div>\
	    			</div></div>'
    			);

		    	if (typeof callback == "function")
		    		callback(data);
		    }
		});
	}
	
	$.fn.float = function(a, b, c) {
		var host = $(this), loop = null;
		host.each(function(i, e) {
			var caller = $(e);
			var delay = a;
			var loop = setInterval(function() {
				var top = caller.css("top").replace("px", "");
				var left = caller.css("left").replace("px", "");
				var right = caller.css("right").replace("px", "");
				var bottom = caller.css("bottom").replace("px", "");
				var maxTop = top + 5 * i;
				var maxLeft = top + 5 * i;
				var maxRight = right + 5 * i;
				var maxBottom = bottom + 5 * i;
				var newLeft = Math.ceil((Math.random() * 50) + maxLeft);
				var newTop = Math.ceil((Math.random() * 250) + maxTop);
				var newRight = Math.ceil((Math.random() * 50) + maxRight);
				var newBottom = Math.ceil((Math.random() * 250) + maxBottom);
				
				caller.css({
					"top": newTop + "px",
					"left": newLeft + "px",
					"bottom": newBottom + "px",
					"right": newRight + "px"
				});
			}, delay);
		});
		if (typeof b != "undefined") {
			clearInterval(loop);
			if (typeof c == "function") c();
		}
	}
	$.loadingBar = function(a) {
		var current = a;
		if (global.lb_progress === 0 && current >= 0.5) {
			$('.global-loading-bar').hide().css("width", 0);
		} else {
			$('.global-loading-bar').show().css("width", (a * 100) + "%");
			global.lb_progress = a;
			if (a === 1) {
				setTimeout(function() {
					$('.global-loading-bar').fadeOut(250, function() {
						$('.global-loading-bar').css("width", 0);
						global.lb_progress = 0;
					});
				}, 1000);
			}
		}
	}
	$.parseReturn = function(a) {
		var str = a.trim().replace(/\t/igm, "");
		var result = {};
		var reKeys = str.match(/^(?:@([\S]+):)/igm);
		var reVals = str.match(/^(?:@[\S]+)(.+)/igm);
		for (var i = 0; i < reKeys.length; i++) {
			var kStr = reKeys[i];
			var kRE = /(?:@([\S]+):)/igm;
			var kMatch = kRE.exec(kStr);
			
			var vStr = reVals[i];
			var vRE = /(?:@[\S]+)(.+)/igm;
			var vMatch = vRE.exec(vStr);
			
			result[ kMatch[1].trim() ] = vMatch[1].trim();
		}
		return result;
	}
	$.confirmation = function(params) {
		$.fn.centerPopupBox = function() {
			var caller = $(this);
			caller.css("top", Math.max(0, (($(window).height() - caller.outerHeight()) / 2)));
			caller.css("left", Math.max(0, (($(window).width() - caller.outerWidth()) / 2)));
		}
		$('body').prepend('<div class="body-dim"></div><div class="confirmation-box"><h1 class="cb-header">Confirmation</h1><p class="cb-content">Are you sure you want to to this?</p><button class="cb-yes">Yes</button><button class="cb-no">No</button></div>');
		$('.confirmation-box').centerPopupBox();
		$('.cb-yes').bind("click", function(event) {
			$('.body-dim').remove();
			$('.confirmation-box').remove();
			params.accept();
		});
		$('.cb-no').bind("click", function(event) {
			$('.body-dim').remove();
			$('.confirmation-box').remove();
			params.decline();
		});
	}
	$.fn.tab = function(a) {
		$(document).on("keydown", $(this), function(event) {
			var code = event.keyCode || event.which;
			if (code == "9") {
				if (typeof a == "function") a();
			}
		});
	}
	$.moduleLeft = function() {
		$(window).bind("scroll", function(event) {
			if ($(this).scrollTop() >= 85) $('.module-left').addClass("module-left-top"); else $('.module-left').removeClass("module-left-top");
		});
	}
	$.closeDialog = function() {
		$('#FCPopupDialog').remove();
		$('#FCPopupDim').remove();
	}
	$.popupDialog = function(params) {
		$.fn.centerFixed = function () {
			$(this).css("top", Math.max(0, (($(window).height() - $(this).outerHeight()) / 2)) + "px");
			$(this).css("left", Math.max(0, (($(window).width() - $(this).outerWidth()) / 2)) + "px");
			return $(this);
		}
		var setWidth = (params.width > 0) ? params.width + "px" : 'auto';
		$.ajax({
			type: "POST",
			url: request.url + "ajax/" + params.file + ".cfm",
			data: params.data,
			cache: false,
			beforeSend: function() {
				$('#FCPopupDialog').remove();
				$('#FCPopupDim').remove();
				$('body').prepend("<div id='FCPopupDim'></div>");
				$('body').prepend("<div id='FCPopupDialog' style='width:" + setWidth + ";'></div>");
			},
			success: function(data) {
				$('#FCPopupDialog').html("<div id='FCPopupDialogInner'>" + data + "</div>");
				$('#FCPopupDialog').centerFixed();
				if (typeof params.success == "function") {
					params.success();
				}
			}
		});
	}
	nf = function(a, b) {
		if (typeof a != "undefined") {
			var d = (a.length <= 0) ? 0 : (a.toString().match(/[^+\-,."'\d]/gi) != null) ? a.toString().replace(/[^+\-,."'\d]/gi, "") : a;
			numberWithCommas = function(c) {
				var parts = c.toString().split(".");
				parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",");
				return parts.join(".");
			}
			var result = {
				num: parseFloat((d.toString()).replace(/,/g, "")),
				str: numberWithCommas((parseFloat((d.toString()).replace(/,/g, ""))).toFixed(2)),
				abs: Math.abs(parseFloat((d.toString()).replace(/,/g, "")).toFixed(2)),
				abs_num: Math.abs(parseFloat((d.toString()).replace(/,/g, "")).toFixed(2)),
				abs_str: numberWithCommas(Math.abs(parseFloat((d.toString()).replace(/,/g, ""))).toFixed(2))
			};
			switch (b)
			{
				case "abs_num":	return result.abs_num;	break;
				case "abs_str":	return result.abs_str;	break;
				case "num":		return result.num;		break;
				case "str":		return result.str;		break;
				case "all":		return result;			break;
				default:		return result.str;		break;
			}
		}
	}
	$.fn.htmlClick = function(a) {
		var caller = $(this);
		$(document).bind("mousedown.eventsGrp", function(event) {
			var target = $(event.target);
			if (!target.is(caller) && !target.is(caller.find('*')))
				if (typeof a == "function") a();
		});
	}
	$.fn.htmlHide = function(a) {
		var caller = $(this);
		$(document).bind("mousedown.eventsGrp", function(event) {
			var target = $(event.target);
			if (!target.is(caller) && !target.is(caller.find('*'))) {
				caller.hide();
				if (typeof a == "function") a();
			}
		});
	}
	$.fn.htmlRemove = function(a) {
		var caller = $(this);
		$(document).bind("mousedown.eventsGrp", function(event) {
			var target = $(event.target);
			if (!target.is(caller) && !target.is(caller.find('*'))) {
				caller.remove();
				if (typeof a == "function") a();
			}
		});
	}
	$.fn.gravity = function(gHost, whiteFlyout, prefPos) {
		var caller = $(this),
			host = $(gHost);
		if (typeof whiteFlyout != "undefined" && whiteFlyout) {
			var flyouts = {
				n: "FCFlyoutNorth_White",
				s: "FCFlyoutSouth_White",
				e: "FCFlyoutEast_White",
				w: "FCFlyoutWest_White"
			};
		} else {
			var flyouts = {
				n: "FCFlyoutNorth",
				s: "FCFlyoutSouth",
				e: "FCFlyoutEast",
				w: "FCFlyoutWest"
			};
		}
		var excessNorth = host.offset().top,
			excessSouth = window.innerHeight - (host.offset().top + host.height()),
			excessEast = window.innerWidth - (host.offset().left + host.width()),
			excessWest = host.offset().left;
		var excessArray = [excessNorth, excessSouth, excessEast, excessWest];
		var mostSpace = Math.max.apply(Math, excessArray);
		var useDir = null;
		switch (mostSpace)
		{
			case excessNorth:
				useDir = 'north';
				break;
			case excessSouth:
				useDir = 'south';
				break;
			case excessEast:
				useDir = (excessSouth >= caller.height() && excessNorth >= caller.height()) ? 'east' : (excessNorth > excessSouth) ? 'north' : 'south';
				break;
			case excessWest:
				useDir = (excessSouth >= caller.height() && excessNorth >= caller.height()) ? 'west' : (excessNorth > excessSouth) ? 'north' : 'south';
				break;
		}
		if (typeof prefPos != "undefined") useDir = prefPos;
		switch (useDir)
		{
			case 'north':
				$('.' + flyouts.n).remove();
				caller.prepend("<div class='" + flyouts.n + "'></div>");
				var flyoutNorth = $('.' + flyouts.n);
				caller.css({
					"left": excessWest - (caller.width() / 2) + (host.width() / 2),
					"top": excessNorth - caller.height() - 20
				});
				flyoutNorth.css({
					"width": caller.width(),
					"margin-top": caller.height()
				});
				break;
			case 'south':
				$('.' + flyouts.s).remove();
				caller.prepend("<div class='" + flyouts.s + "'></div>");
				var flyoutSouth = $('.' + flyouts.s);
				caller.css({
					"left": excessWest - (caller.width() / 2) + (host.width() / 2),
					"top": excessNorth + host.height() + 20
				});
				flyoutSouth.css({
					"width": caller.width(),
					"margin-top": "-9px"
				});
				break;
			case 'east':
				$('.' + flyouts.e).remove();
				caller.prepend("<div class='" + flyouts.e + "'></div>");
				var flyoutEast = $('.' + flyouts.e);
				caller.css({
					"left": excessWest + host.width() + 20,
					"top": excessNorth - (caller.height() / 2) + (host.height() / 2)
				});
				flyoutEast.css({
					"height": caller.height(),
					"margin-left": "-9px"
				});
				break;
			case 'west':
				$('.' + flyouts.w).remove();
				caller.prepend("<div class='" + flyouts.w + "'></div>");
				var flyoutWest = $('.' + flyouts.w);
				caller.css({
					"left": excessWest - caller.width() - 20,
					"top": excessNorth - (caller.height() / 2) + (host.height() / 2)
				});
				flyoutWest.css({
					"height": caller.height(),
					"margin-left": caller.width()
				});
				break;
		}
	}
	$.messageBox = function(a, b, c) {
		var _params = {
			id: "sle-message-box",
			height: 100,
			easing: 300,
			delay: 2000
		};
		$(document).unbind(".msgBoxEvents");
		$('#' + _params.id).each(function(index, element) {
			$(element).remove();
		});
		var _style = "display: none;position: fixed;width:100%;height: 0px;background: rgba(139, 173, 52, 0.9);text-align: center;line-height: 0px;font-size: 16px;color: #FFF;z-index: 0;bottom: 0;left: 0;pointer-events:none;";
		$('body').prepend("<div id='" + _params.id + "' style='" + _style + "'></div>");
		var _box = $('#' + _params.id);
		if (b == "error")
			_box.css("background", "rgba(173, 52, 52, 0.9)");
		_box
			.html(a)
			.fadeTo(_params.easing, 0.9)
			.animate({"height": _params.height, "line-height": _params.height + "px"}, _params.easing, 'easeInOutCubic');
		setTimeout(function(){
			_box.animate({
				"height": "50px",
				"line-height": "50px"
			}, _params.easing, 'easeInOutCubic', function() {
				$(document).bind("click.msgBoxEvents", function(event) {
					_box.animate({
						"height": "0",
						"line-height": "0"
					 }, _params.easing, 'easeInOutCubic', function() {
						_box.remove();
						if (typeof c == "function") c();
					 });
				});
			});
		}, _params.delay);
	}
})(jQuery);