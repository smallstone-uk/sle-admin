window.Barcode="";
window.keypad="";
window.keypadDecimal="";
window.touchtime=0;
window.touchhold=false;
window.touchHoldDelay=400;
window.cashonlyError=false;
window.cashOnlyTotal=0;
window.basketTotal=0;

;(function($) {
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
				var width = caller.css("width").replace("px", "");
				var height = caller.css("height").replace("px", "");
				var maxTop = top + 5 * i;
				var maxLeft = top + 5 * i;
				var maxRight = right + 5 * i;
				var maxBottom = bottom + 5 * i;
				var newLeft = Math.ceil((Math.random() * 50) + maxLeft);
				var newTop = Math.ceil((Math.random() * 250) + maxTop);
				var newRight = Math.ceil((Math.random() * 50) + maxRight);
				var newBottom = Math.ceil((Math.random() * 250) + maxBottom);
				var newWidth = Math.ceil((Math.random() * 130) + 160);
				var randOpacity = Math.random();
				
				caller.css({
					"top": newTop + "px",
					"left": newLeft + "px",
					"bottom": newBottom + "px",
					"right": newRight + "px",
					"opacity": randOpacity,
					"width": newWidth,
					"height": newWidth
				});
			}, delay);
		});
		if (typeof b != "undefined") {
			clearInterval(loop);
			if (typeof c == "function") c();
		}
	}
	$.fn.currentTime = function(a) {
		var caller = $(this);
		setInterval(function() {
			var d = new Date();
			var str = (typeof a != "undefined" && a === 1) ?
				('0' + d.getHours()).slice(-2) + ":" + ('0' + d.getMinutes()).slice(-2) + ":" + ('0' + d.getSeconds()).slice(-2) :
				('0' + d.getHours()).slice(-2) + ":" + ('0' + d.getMinutes()).slice(-2);
			caller.html(str);
		}, 1000);
	}
	$.keypadFocus = function(title, message, on, callback) {
		$('#keypad').eyeFocus({
			position: "fixed",
			on: on,
			popup: true,
			popupTitle: title,
			popupMessage: message,
			cancel: function() {
				$('#btnEnter').unbind("click");
			},
			success: function() {
				if (typeof callback == "function") callback();
			}
		});
	}
	$.confirmation = function(params) {
		$('.confirm_box').remove();
		window.confirmationAction = function() { params.action(); $('.confirm_box').remove(); }
		window.confirmationCancel = function() { $('.confirm_box').remove(); }
		var positive = (typeof params.positive != "undefined") ? params.positive : "Yes";
		var negative = (typeof params.negative != "undefined") ? params.negative : "No";
		$('body').prepend(
			"<div class='confirm_box'>" +
			"<div class='confirm_box_msg'>" + params.message + "</div>" +
			"<button onclick='window.confirmationAction();' style='background:#548843'>" +
			positive +
			"</button><button onclick='window.confirmationCancel();' style='background:#844'>" +
			negative +
			"</button></div>"
		);
		var height=Number($('.confirm_box').css("height").replace("px", ""));
		var paddingtop=Number($('.confirm_box').css("padding-top").replace("px", ""));
		var paddingbottom=Number($('.confirm_box').css("padding-bottom").replace("px", ""));
		$('.confirm_box').css("margin-top",(((height+paddingtop+paddingbottom+50) * -1) / 2) + "px");
	}
	$.logout = function() {
		$.ajax({
			type: "GET",
			url: "AJAX_logout.cfm",
			success: function(data) {
				$.messageBox("Logged Out", "success");
			}
		});
	}
	$.fn.center = function(a, b) {
		var caller = $(this);
		var posType = (typeof b == "undefined") ? "absolute" : b;
		
		caller.css("position", posType);
		
		if (typeof a != "undefined") {
			switch(a)
			{
				case "top":
					caller.css("top", Math.max(0, (($(window).height() - caller.outerHeight()) / 2) + $(window).scrollTop()) + "px");
					break;
				case "left":
					caller.css("left", Math.max(0, (($(window).width() - caller.outerWidth()) / 2) + $(window).scrollLeft()) + "px");
					break;
			}
		} else {
			caller.css("top", Math.max(0, (($(window).height() - caller.outerHeight()) / 2) + $(window).scrollTop()) + "px");
			caller.css("left", Math.max(0, (($(window).width() - caller.outerWidth()) / 2) + $(window).scrollLeft()) + "px");
		}
	}
	cut = function(str, cutStart, cutEnd) {
	  return str.substr(0, cutStart) + str.substr(cutEnd + 1);
	}
	setCaretPosition = function(elemId, caretPos) {
		var elem = document.getElementById(elemId);
		if (elem != null) {
			if (elem.createTextRange) {
				var range = elem.createTextRange();
				range.move('character', caretPos);
				range.select();
			} else {
				if (elem.selectionStart) {
					elem.focus();
					elem.setSelectionRange(caretPos, caretPos);
				} else {
					elem.focus();
				}
			}
		}
	}
	getCaretPosition = function(oField) {
		var iCaretPos = 0;
		if (document.selection) {
			oField.focus();
			var oSel = document.selection.createRange();
			oSel.moveStart('character', -oField.value.length);
			iCaretPos = oSel.text.length;
		} else if (oField.selectionStart || oField.selectionStart == '0') {
			iCaretPos = oField.selectionStart;
		}
		return (iCaretPos);
	}
	insertAtCaret = function(areaId, text) {
		var txtarea = document.getElementById(areaId);
		var scrollPos = txtarea.scrollTop;
		var strPos = 0;
		var br = ((txtarea.selectionStart || txtarea.selectionStart == '0') ? 
			"ff" : (document.selection ? "ie" : false ) );
		if (br == "ie") { 
			txtarea.focus();
			var range = document.selection.createRange();
			range.moveStart ('character', -txtarea.value.length);
			strPos = range.text.length;
		}
		else if (br == "ff") strPos = txtarea.selectionStart;
	
		var front = (txtarea.value).substring(0,strPos);  
		var back = (txtarea.value).substring(strPos,txtarea.value.length); 
		txtarea.value=front+text+back;
		strPos = strPos + text.length;
		if (br == "ie") { 
			txtarea.focus();
			var range = document.selection.createRange();
			range.moveStart ('character', -txtarea.value.length);
			range.moveStart ('character', strPos);
			range.moveEnd ('character', 0);
			range.select();
		}
		else if (br == "ff") {
			txtarea.selectionStart = strPos;
			txtarea.selectionEnd = strPos;
			txtarea.focus();
		}
		txtarea.scrollTop = scrollPos;
	}
	$.fn.htmlClick = function(a) {
		var caller = $(this);
		$(document).bind("mousedown.eventsGrp", function(event) {
			var target = $(event.target);
			if (!target.is(caller) && !target.is(caller.find('*')))
				if (typeof a == "function") a();
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
	getDataAttributes = function(node) {
		var d = {}, re_dataAttr = /^data\-(.+)$/;
		$.each(node.get(0).attributes, function(index, attr) {
			if (re_dataAttr.test(attr.nodeName)) {
				var key = attr.nodeName.match(re_dataAttr)[1];
				d[key] = attr.value;
			}
		});
		return d;
	}
	/*$.virtualKeyboard = function(a, b) {
		var presetText = (typeof a != "undefined" && typeof a != "function") ? a : "";
		$('.virtual_numpad').animate({
			"bottom": "-1000px"
		}, 500, "easeInOutCubic");
		$('.vk_text').val(presetText).focus();
		$('body').prepend("<div class='dim'></div>");
		$('.dim').fadeIn(500);
		$('.virtual_keyboard').center("left", "fixed");
		$('.virtual_keyboard').animate({
			"bottom": "1%"
		}, 500, "easeInOutCubic");
		if ($('.vk_text').val().length == 0) {window.startShift = true;}
		$('.virtual_keyboard span[data-function="enter"]').bind("click", function(event) {
			$('.dim').fadeOut(500, function() {$('.dim').remove()});
			$('.virtual_keyboard').animate({
				"bottom": "-1000px"
			}, 500, "easeInOutCubic");
			if (typeof a != "undefined" && typeof a == "function") {
				a($('.vk_text').val());
			} else if (typeof b != "undefined" && typeof b == "function") {
				b($('.vk_text').val());
			}
			$('.virtual_keyboard span[data-function="enter"]').unbind("click");
		});
	}*/
	/*$.virtualNumpad = function(a, b, c, d) {
		var presetText = (typeof a != "undefined" && typeof a != "function") ? a : "";
		$('.virtual_keyboard').animate({
			"bottom": "-1000px"
		}, 500, "easeInOutCubic");
		$('.vkn_text').val(presetText).focus();
		$('body').prepend("<div class='dim'></div>");
		$('.dim').fadeIn(500);
		$('.virtual_numpad').center("left", "fixed");
		$('.virtual_numpad').animate({
			"bottom": "1%"
		}, 500, "easeInOutCubic");
		window.vkn_allowDecimal = (typeof c != "undefined") ? false : true;
		window.vkn_maxLength = (typeof d != "undefined") ? d : -1;
		$('.vkn_enter').bind("click", function(event) {
			$('.dim').fadeOut(500, function() {$('.dim').remove()});
			$('.virtual_numpad').animate({
				"bottom": "-1000px"
			}, 500, "easeInOutCubic");
			if (typeof a != "undefined" && typeof a == "function") {
				a($('.vkn_text').val());
			} else if (typeof b != "undefined" && typeof b == "function") {
				b($('.vkn_text').val());
			}
			$('.vkn_enter').unbind("click");
			window.vkn_allowDecimal = true;
		});
	}*/
	$.virtualKeyboard = function(params) {
		var presetText = (typeof params.text != "undefined") ? params.text : "";
		$('.vk_hint').remove();
		$('.virtual_numpad').animate({
			"bottom": "-1000px"
		}, 500, "easeInOutCubic");
		$('.vk_text').val(presetText).focus();
		$('body').prepend("<div class='dim'></div>");
		$('.dim').fadeIn(500);
		$('.virtual_keyboard').center("left", "fixed");
		$('.virtual_keyboard').animate({
			"bottom": "1%"
		}, 500, "easeInOutCubic");
		if ($('.vk_text').val().length == 0) window.startShift = true;
		if (typeof params.hint != "undefined") $('.virtual_keyboard').prepend("<div class='vk_hint'>" + params.hint + "</div>");
		$('.virtual_keyboard span[data-function="enter"]').bind("click", function(event) {
			$('.dim').fadeOut(500, function() {$('.dim').remove()});
			$('.virtual_keyboard').animate({
				"bottom": "-1000px"
			}, 500, "easeInOutCubic");
			if (typeof params.action != "undefined" && typeof params.action == "function") params.action($('.vk_text').val());
			$('.virtual_keyboard span[data-function="enter"]').unbind("click");
		});
	}
	$.virtualNumpad = function(params) {
		var presetText = (typeof params.text != "undefined") ? params.text : "";
		$('.vkn_hint').remove();
		$('.virtual_keyboard').animate({
			"bottom": "-1000px"
		}, 500, "easeInOutCubic");
		$('.vkn_text').val(presetText).focus();
		$('body').prepend("<div class='dim'></div>");
		$('.dim').fadeIn(500);
		$('.virtual_numpad').center("left", "fixed");
		$('.virtual_numpad').animate({
			"bottom": "1%"
		}, 500, "easeInOutCubic");
		window.vkn_allowDecimal = (typeof params.decimal == "undefined") ? true : params.decimal;
		window.vkn_maxLength = (typeof params.maxlength != "undefined") ? params.maxlength : -1;
		if (typeof params.hint != "undefined") $('.virtual_numpad').prepend("<div class='vkn_hint'>" + params.hint + "</div>");
		$('.vkn_enter').bind("click", function(event) {
			$('.dim').fadeOut(500, function() {$('.dim').remove()});
			$('.virtual_numpad').animate({
				"bottom": "-1000px"
			}, 500, "easeInOutCubic");
			if (typeof params.action != "undefined" && typeof params.action == "function") params.action($('.vkn_text').val());
			$('.vkn_enter').unbind("click");
			window.vkn_allowDecimal = true;
		});
	}
	$.fn.touchHold = function(a) {
		var caller = $(this), width = 400, delay = window.touchHoldDelay;
		
		if ($.contains(document, caller[0])) {
			caller.on("mousedown", function() {
				var me = $(this);
				me.addClass("active");
				window.touchtime = setTimeout(function() {
					window.touchhold = true;
					window.touchHoldAction = function(index) {
						a[index].action(attributes, me);
						$('.touch_menu').remove();
					}
					me.removeClass("active");
					var listStr = "";
					var attributes = getDataAttributes(me);
					for (var i = 0; i < a.length; i++) {
						var b = a[i];
						a[i].index = i;
						if (typeof b.action == "function")
							listStr += "<li onclick='javascript:window.touchHoldAction(" + i + ");'>" + b.text + "</li>";
					}
					
					$('body').prepend("<ul class='touch_menu'><div class='touch_menu_inner'>" + listStr + "</div></ul>");
					if ($.contains(document, $('.touch_menu')[0])) {
						var menuHalfWidth = width / 2;
						$('.touch_menu').htmlRemove(function() {
							me.removeClass("touch_menu_active");
						});
						$('.touch_menu').gravity(me, false, "south", 0, false);
						$('.touch_menu').css("left", (me.offset().left - menuHalfWidth + me.width() / 2));
					
						$('.touch_menu').show().animate({
							"width": width + "px"
						}, 500, 'easeInOutCubic');
						
						me.addClass("touch_menu_active");
					}
					
				}, delay);
			});
			
			caller.on("mouseup mouseleave", function() {
				clearTimeout(window.touchtime);
			});
			
			$(document).bind("click", function() {
				window.touchtime = 0;
				window.touchhold = false;
			});
		}
	}
	tillFormat = function(a) {
		return (Number(a) / 100).toFixed(2);
	}
	nf = function(a, b) {
		if (typeof a != "undefined") {
			var d = (a.length <= 0) ? 0 : (a.toString().match(/[^+\-,."'\d]/gi) != null) ? a.toString().replace(/[^+\-,."'\d]/gi, "") : a;
			var dStr = d.toString();
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
	String.prototype.isNumber = function(){return /^(\d|\.)+$/.test(this);}
	String.prototype.toJava = function() {
		var a = this;
		var result = {};
		var str = a.trim().replace(/\t/igm, "");
		var arr = str.split("@");
		for (var i = 0; i < arr.length; i++) {
			if (arr[i].length > 0) {
				var element = arr[i].split(":");
				var isNum = element[1].trim().isNumber();
				var value = (isNum) ? Number(element[1].trim()) : element[1].trim();
				result[ element[0].trim() ] = value;
			}
		}
		return result;
	}
	$.parseReturn = function(a) {
		var result = {};
		var str = a.trim().replace(/\t/igm, "");
		var arr = str.split("@");
		for (var i = 0; i < arr.length; i++) {
			if (arr[i].length > 0) {
				var element = arr[i].split(":");
				var isNum = element[1].trim().isNumber();
				var value = (isNum) ? Number(element[1].trim()) : element[1].trim();
				result[ element[0].trim() ] = value;
			}
		}
		return result;
	}
	$.messageBox = function(a, b, c, d) {
		var _params = {
			id: "sle-message-box",
			height: 40,
			easing: 100,
			delay: 8000
		};
		_params.delay = (typeof d == "undefined") ? _params.delay : d;
		$(document).unbind(".msgBoxEvents");
		$('#' + _params.id).each(function(index, element) {
			$(element).remove();
		});
		$('body').prepend("<div id='" + _params.id + "' class='msgbox noprint'></div>");
		var _box = $('#' + _params.id);
		if (typeof b != "undefined" && b == "error") {
			_box.css("background", "rgba(173, 52, 52, 0.9)");
		} else {
			_box.css("background", "rgba(139, 173, 52, 0.9)");
		}
		_box
			.html(a)
			.fadeTo(_params.easing, 0.9)
			.animate({
				"top": 0,
				"height": _params.height + "px",
				"line-height": _params.height + "px"
			}, _params.easing, 'easeInOutCubic');
		
		if (_params.delay != 0) {
			setTimeout(function(){
				_box.animate({
					"top": (_params.height * -1) + "px",
					"line-height": _params.height + "px"
				}, _params.easing, 'easeInOutCubic', function() {
					_box.animate({
						"height": "0",
						"line-height": "0"
					 }, _params.easing, 'easeInOutCubic', function() {
						_box.remove();
						if (typeof c == "function") c();
					 });
				});
			}, _params.delay);
		}
	}
	
	$.fn.gravity = function(gHost, whiteFlyout, prefPos, offset, allowFlyout) {
		var caller = $(this),
			host = $(gHost);
		var callerHeight = caller.height();
		var padding = {
			top: Number(host.css("padding-top").replace("px", "")),
			bottom: Number(host.css("padding-bottom").replace("px", "")),
			left: Number(host.css("padding-left").replace("px", "")),
			right: Number(host.css("padding-right").replace("px", ""))
		};
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
		var recommendedDir = mostSpace;
		var useDir = null;
		var offsetToUse = (typeof offset == "undefined") ? 20 : Number(offset);
		var showFlyout = (typeof allowFlyout != "undefined") ? allowFlyout : true;
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
		
		var keys = {
			north: excessNorth,
			south: excessSouth,
			east: excessEast,
			west: excessWest
		};
		
		if (typeof prefPos != "undefined") {
			if (prefPos != "auto") {
				if (keys[prefPos] > callerHeight) {
					useDir = prefPos;
				} else {
					if (keys[prefPos] < recommendedDir) {
						switch (prefPos)
						{
							case "north":
								useDir = "south";
								break;
							case "south":
								useDir = "north";
								break;
							case "east":
								useDir = "west";
								break;
							case "west":
								useDir = "east";
								break;
						}
					} else {
						useDir = prefPos;
					}
				}
			}
		}
		
		switch (useDir)
		{
			case 'north':
				$('.' + flyouts.n).remove();
				if (showFlyout) {
					caller.prepend("<div class='" + flyouts.n + "'></div>");
					var flyoutNorth = $('.' + flyouts.n);
					flyoutNorth.css({
						"width": caller.width(),
						"margin-top": caller.height() - 1
					});
				}
				caller.css({
					"left": excessWest - (caller.width() / 2) + (host.width() / 2),
					"top": excessNorth - caller.height() - offsetToUse
				});
				break;
			case 'south':
				$('.' + flyouts.s).remove();
				if (showFlyout) {
					caller.prepend("<div class='" + flyouts.s + "'></div>");
					var flyoutSouth = $('.' + flyouts.s);
					flyoutSouth.css({
						"width": caller.width(),
						"margin-top": "-8px"
					});
				}
				caller.css({
					"left": excessWest - (caller.width() / 2) + (host.width() / 2),
					"top": excessNorth + host.height() + offsetToUse + (padding.bottom + padding.top)
				});
				break;
			case 'east':
				$('.' + flyouts.e).remove();
				if (showFlyout) {
					caller.prepend("<div class='" + flyouts.e + "'></div>");
					var flyoutEast = $('.' + flyouts.e);
					flyoutEast.css({
						"height": caller.height(),
						"margin-left": "-8px"
					});
				}
				caller.css({
					"left": excessWest + host.width() + offsetToUse,
					"top": excessNorth - (caller.height() / 2) + (host.height() / 2)
				});
				break;
			case 'west':
				$('.' + flyouts.w).remove();
				if (showFlyout) {
					caller.prepend("<div class='" + flyouts.w + "'></div>");
					var flyoutWest = $('.' + flyouts.w);
					flyoutWest.css({
						"height": caller.height(),
						"margin-left": caller.width() - 1
					});
				}
				caller.css({
					"left": excessWest - caller.width() - offsetToUse,
					"top": excessNorth - (caller.height() / 2) + (host.height() / 2)
				});
				break;
		}
	}
	$.fn.eyeFocus = function(params) {
		var caller = $(this);
		var popupWidth = 0;
		$('.FCEyeFocus').remove();
		$('.FCEyeFocusPopup').remove();
		if (params.on) {
			caller.before("<div class='FCEyeFocus'></div>");
			caller.css({
				"position": params.position,
				"z-index": "99999999"
			});
			if (params.popup) {
				$('body').prepend("<div class='FCEyeFocusPopup'><button class='FCEFButton'>X</button><div class='FCEFPMessage'><h1>" + params.popupTitle + "</h1><p>" + params.popupMessage + "</p></div></div>");
				$('.FCEyeFocusPopup').gravity(caller, true, "north");
				popupWidth = $('.FCEyeFocusPopup').width() - 32;
				$('.FCEFButton').css("margin-left",popupWidth+"px");
			}
		} else {
			caller.css({
				"position": "",
				"z-index": ""
			});
		}
		if (typeof params.success == "function") {
			params.success();
		}
		
		$('.FCEFButton').bind("click", function(e) {
			$('.FCEyeFocus, .FCEyeFocusPopup').remove();
			$('#btnEnter').removeClass("active");
			$.KeypadClear();
			$.CloseOverlay();
			if (typeof params.cancel != "undefined" && typeof params.cancel == "function") params.cancel();
		});
	}
	
	
	//EPOS Functions
	$.Scanner=function(a) {
		var code=window.Barcode;
		if (a.keyCode == 13) {
			if (code.length >= 8 & code.length <= 14) {
				//console.log(window.Barcode);
				$.GetBarcode(window.Barcode);
				window.Barcode="";
			} else {
				window.Barcode="";
			}
		} else {
			if (code != "") {
				var currentString=code;
				var newString=currentString+String.fromCharCode(a.keyCode);
			} else {
				var newString=String.fromCharCode(a.keyCode);
			}
			window.Barcode=newString;
		}
	}
	$.GetBarcode=function(a) {
		$.ajax({
			type: 'POST',
			url: 'AJAX_GetBarcode.cfm',
			data: {"barcode":a},
			success:function(data){
				var result=$.parseReturn(data);
				if (result.error == "true") {
					$.messageBox("Product not found","error");
				} else {
					$.LoadProduct(a,Number(result.id),Number(result.price),result.type,1);
					//console.log(result);
				}
			}
		});
	}
	$.addToBasket = function(params) {
		$.ajax({
			type: "POST",
			url: "AJAX_addToBasket.cfm",
			data: params,
			success: function(data) {
				$('#basket').html(data);
				$('#basket').LoadBasket();
			}
		});
	}
	$.LoadProduct=function(a,b,c,d,e) {
		var qty = (typeof e == "undefined" && e == "0") ? 1 : e;
		$.ajax({
			type: 'POST',
			url: 'AJAX_LoadProduct.cfm',
			data: {"barcode":a,"prodID":b,"manualprice":c,"type":d,"qty":qty},
			success:function(data){
				var result=data.toJava();
				if (Number(result.price) == 0) {
					//iFocus number pad function
				} else {
					$.addToBasket(result);
				}
				//console.log(result);
			}
		});
	}
	$.fn.LoadBasket=function(a,b) {
		var selector=$(this);
		var changedue = (typeof a == "undefined") ? 0 : a;
		$.ajax({
			type: 'POST',
			url: 'AJAX_Basket.cfm',
			data: {"changedue": changedue},
			success:function(data){
				selector.html(data);
				if (typeof b == "function") b();
			}
		});
	}
	$.fn.LoadPrevTrans=function(a) {
		var selector=$(this);
		$.ajax({
			type: 'GET',
			url: 'AJAX_LoadPrevTrans.cfm',
			success:function(data){
				selector.html(data);
				if (typeof a == "function") a();
			}
		});
	}
	$.fn.LoadCats=function() {
		var selector=$(this);
		$.ajax({
			type: 'GET',
			url: 'AJAX_LoadCats.cfm',
			success:function(data){
				selector.html(data);
			}
		});
	}
	$.fn.LoadCatProducts=function(a,b) {
		var selector=$(this);
		var display=$(this).css("display");
		if (b != "") {
			var file=b;
		} else {
			var file="AJAX_LoadCatProducts.cfm";
		}
		$.ajax({
			type: 'POST',
			url: file,
			data: {"id":a,"file":file},
			beforeSend: function(){
				if (display == "block") {
					selector.stop().fadeOut();
				}
			},
			success:function(data){
				selector.html(data).stop().fadeIn();
			}
		});
	}
	$.TransPayment=function(a,b,c) {
		$.ajax({
			type: 'POST',
			url: 'AJAX_TransPayment.cfm',
			data: {"type":a,"subtype":b,"amount":c},
			success:function(data){
				var result=$.parseReturn(data);
				console.log(result);
				if (Number(result.transID) === 0) {
					if (result.error1 == "true") {
						$.messageBox("CASH ONLY items must be paid by cash or cash back.","error");
						window.cashonlyError=true;
					} else {
						$('#basket').LoadBasket(Number(result.changedue));
					}
				} else {
					$('#basket').LoadBasket(Number(result.changedue));
					$.messageBox("Transaction Complete","success");
					$.PrintReceipt(Number(result.transID),Number(c),Number(result.cashonly));
				}
				$.KeypadClear();
				$.CloseOverlay();
			}
		});
	}
	$.fn.ClearBasket=function() {
		var selector=$(this);
		$.ajax({
			type: 'GET',
			url: 'AJAX_ClearBasket.cfm',
			success:function(data){
				selector.LoadBasket();
			}
		});
	}
	$.CloseOverlay=function() {
		$('#overlay').stop().fadeOut();
		$('.function').removeClass("active");
		$('.backtobasket').fadeOut();
	}
	$.fn.LoadKeypad=function() {
		var selector=$(this);
		$.ajax({
			type: 'GET',
			url: 'AJAX_Keypad.cfm',
			success:function(data){
				selector.html(data);
			}
		});
	}
	$.fn.Keypad=function(a) {
		var selector = $(this);
		window.keypad += a;
		var numbers = window.keypad;
		var decimal = window.keypadDecimal;
		var keypadtotal = "";
		var display = "";
		keypadtotal += numbers;
		display = tillFormat(keypadtotal);
		window.keypadDecimal = display;
		selector.html(display);
	}
	$.KeypadClear=function() {
		window.keypad="";
		window.keypadDecimal="";
		$('#keypad #result').html("0");
	}
	
	//////////////////////// Payment Types ////////////////////////
	$.AddPrize = function(type, subtype) {
		$.keypadFocus("Prize", "Please enter the prize amount", true);
		$('#btnEnter').addClass("active").unbind("click");
		$('#btnEnter').bind("click", function(e) {
			amount = Number(window.keypadDecimal);
			if (amount > 0) { 
				$.keypadFocus("", "", false, function() {
					$.TransPayment(type, subtype, amount);
					$.KeypadClear();
					$.CloseOverlay();
					$('#btnEnter').removeClass("active").unbind("click");
				});
			} else {
				$.messageBox("Please enter an amount","error");
			}
			e.preventDefault();
		});
	}
	
	$.PaymentCard=function(params) {
		//console.log(params);
		var amount = Number(params.amount);
		var subtotal = Number(params.subtotal);
		var type = params.type;
		var subtype = params.subtype;
		var cashOnlyTotal = nf(params.cashOnlyTotal, "str");
		var basketTotal = nf(params.basketTotal, "str");
		var otherItemsTotal = nf(basketTotal - cashOnlyTotal, "str");
		if (amount === 0) {
			if (cashOnlyTotal > 0) {
				$.keypadFocus("Card", "Cash Only Items: <b style='font-size:14px;'>&pound;"+cashOnlyTotal+"</b><br>Other Items: <b style='font-size:14px;'>&pound;"+otherItemsTotal+"</b><br>Basket Total: <b style='font-size:14px;'>&pound;"+basketTotal+"</b><h3>How to correctly complete this transaction</h3><p>As you have <b>Cash Only</b> items in your basket and you first payment is card, you have to follow these steps to complete the transaction correctly.</p><p><ol><li>Enter <b>&pound;"+otherItemsTotal+"</b> into PayPoint as amount to charge card.</li><li>Say <b>YES to Cash Back</b> and enter <b>&pound;"+cashOnlyTotal+"</b> as cash back</li><li>The total amount you are charging the customer on PayPoint should now match <b>&pound;"+basketTotal+"</b>. If not, revise previous steps.</li></ol></p><p>Please enter the amount shown on the <b>PayPoint receipt.</b></p>", true);
			} else {
				$.keypadFocus("Card", "Basket Total: <b style='font-size:14px;'>&pound;"+basketTotal+"</b><p>Please enter the amount shown on the <b>PayPoint receipt.</b></p>", true);
			}
			$('#btnEnter').addClass("active").unbind("click");
			$('#btnEnter').bind("click", function(e) {
				amount = Number(window.keypadDecimal);
				if (amount > 0 && subtotal > 0) { 
					$.keypadFocus("", "", false, function() {
						$.TransPayment(type,subtype,amount);
						$.KeypadClear();
						$.CloseOverlay();
						$('#btnEnter').removeClass("active").unbind("click");
					});
				} else {
					$.messageBox("Please enter an amount.","error");
				}
				e.preventDefault();
			});
		} else {
			$.TransPayment(type,subtype,window.keypadDecimal);
		}
	}
	$.PaymentCash=function(a,b,c,d) {
		var amount = Math.abs(Number(a));
		var subtotal = Math.abs(Number(b));
		var type = c;
		var subtype = d;
		if (amount === 0) {
			$.keypadFocus("Cash", "Enter the amount of cash given by the customer. Or if the total cash given is correct, just hit enter.", true);
			$('#btnEnter').addClass("active").unbind("click");
			$('#btnEnter').bind("click", function(e) {
				amount = Number(window.keypadDecimal);
				if (window.cashonlyError) {
					$.confirmation({
						message: "<h1>Confirm</h1>Are you sure you have recieved cash for the CASH ONLY item(s)?",
						action: function() {
							if (amount > 0 && subtotal > 0) {
								$.keypadFocus("", "", false, function() {
									$.TransPayment(type,subtype,amount);
									$.KeypadClear();
									$.CloseOverlay();
									$('#btnEnter').removeClass("active").unbind("click");
								});
							} else if (subtotal > 0) {
								$.keypadFocus("", "", false, function() {
									$.TransPayment(type,subtype,subtotal);
									$.KeypadClear();
									$.CloseOverlay();
									$('#btnEnter').removeClass("active").unbind("click");
								});
							}
						}
					});
				} else {
					if (amount > 0 && subtotal > 0) {
						$.keypadFocus("", "", false, function() {
							$.TransPayment(type,subtype,amount);
							$.KeypadClear();
							$.CloseOverlay();
							$('#btnEnter').removeClass("active").unbind("click");
						});
					} else if (subtotal > 0) {
						$.keypadFocus("", "", false, function() {
							$.TransPayment(type,subtype,subtotal);
							$.KeypadClear();
							$.CloseOverlay();
							$('#btnEnter').removeClass("active").unbind("click");
						});
					}
				}
				e.preventDefault();
			});
		} else {
			$.TransPayment(type,subtype,window.keypadDecimal);
		}
	}
	$.PaymentCheque=function(a,b,c,d) {
		var amount = Number(a);
		var subtotal = Number(b);
		var type = c;
		var subtype = d;
		if (amount === 0) {
			$.keypadFocus("Cheque", "Enter the amount written on the cheque.", true);
			$('#btnEnter').addClass("active").unbind("click");
			$('#btnEnter').bind("click", function(e) {
				amount = Number(window.keypadDecimal);
				if (amount <= subtotal && subtotal > 0) { 
					$.keypadFocus("", "", false, function() {
						$.TransPayment(type,subtype,amount);
						$.KeypadClear();
						$.CloseOverlay();
						$('#btnEnter').removeClass("active").unbind("click");
					});
				} else {
					if (amount > subtotal) {
						$.messageBox("Cheque amount cannot exceed basket sub total","error");
					} else {
						$.messageBox("Please enter an amount","error");
					}
				}
				e.preventDefault();
			});
		} else {
			$.TransPayment(type,subtype,window.keypadDecimal);
		}
	}
	$.PaymentNewsVoucher=function(a,b,c,d) {
		var amount = Number(a);
		var subtotal = Number(b);
		var type = c;
		var subtype = d;
		if (amount === 0) {
			$.keypadFocus("Newspaper Voucher", "Please enter the amount the voucher is worth.", true);
			$('#btnEnter').addClass("active").unbind("click");
			$('#btnEnter').bind("click", function(e) {
				amount = Number(window.keypadDecimal);
				if (amount > 0 && subtotal > 0) { 
					$.keypadFocus("", "", false, function() {
						$.TransPayment(type,subtype,amount);
						$.KeypadClear();
						$.CloseOverlay();
						$('#btnEnter').removeClass("active").unbind("click");
					});
				} else {
					$.messageBox("Please enter an amount.","error");
				}
				e.preventDefault();
			});
		} else {
			$.TransPayment(type,subtype,window.keypadDecimal);
		}
	}
	$.PaymentCoupon=function(a,b,c,d) {
		var amount = Number(a);
		var subtotal = Number(b);
		var type = c;
		var subtype = d;
		if (amount === 0) {
			$.keypadFocus("Coupon", "Please enter the amount the coupon is worth.", true);
			$('#btnEnter').addClass("active").unbind("click");
			$('#btnEnter').bind("click", function(e) {
				amount = Number(window.keypadDecimal);
				if (amount > 0 && subtotal > 0) { 
					$.keypadFocus("", "", false, function() {
						$.TransPayment(type,subtype,amount);
						$.KeypadClear();
						$.CloseOverlay();
						$('#btnEnter').removeClass("active").unbind("click");
					});
				} else {
					$.messageBox("Please enter an amount.","error");
				}
				e.preventDefault();
			});
		} else {
			$.TransPayment(type,subtype,window.keypadDecimal);
		}
	}
	$.PaymentSupplier=function(a,b,c,d) {
		var amount = Number(a);
		var subtotal = Number(b);
		var type = c;
		var subtype = d;
		if (amount === 0) {
			$.keypadFocus("Supplier", "Please enter the supplier invoice total. Please make sure you have checked the items delivered match the invoice and the quantities are correct.", true);
			$('#btnEnter').addClass("active").unbind("click");
			$('#btnEnter').bind("click", function(e) {
				amount = Number(window.keypadDecimal);
				if (amount > 0) { 
					$.keypadFocus("", "", false, function() {
						$.TransPayment(type,subtype,amount);
						$.KeypadClear();
						$.CloseOverlay();
						$('#btnEnter').removeClass("active").unbind("click");
					});
				} else {
					$.messageBox("Please enter an amount.","error");
				}
				e.preventDefault();
			});
		} else {
			$.TransPayment(type,subtype,window.keypadDecimal);
		}
	}
	//////////////////////// End Payment Types ////////////////////////
	
	
	$.PrintReceipt=function(a,b,c) {
		if (typeof a == "undefined") {var id=0;} else {var id=a;}
		if (typeof b == "undefined") {var amount=0;} else {var amount=b;}
		if (typeof c == "undefined") {var cashonly=0;} else {var cashonly=c;}
		$.ajax({
			type: 'POST',
			url: 'AJAX_Receipt2.cfm',
			data: {"transID":id,"amount":amount,"cashonly":cashonly},
			success:function(data){
				$('#receiptresult').html(data).fadeIn(function() {
					window.print();
				});
			}
		});
	}
	$.OpenBackoffice=function() {
		$('.backoffice-overlay').fadeToggle();
	}
	$.LoadBOFunctions=function(id,file) {
		$.ajax({
			type: 'POST',
			url: file,
			data: {"id":id,"file":file},
			success:function(data){
				$('#bocontent').html(data);
			}
		});
	}
	$.OpenTill=function() {
		$('#receiptresult').html("");
		window.print();
	}
	$.fn.BOLoadCatProducts=function(a) {
		var selector=$(this);
		var display=$(this).css("display");
		$.ajax({
			type: 'POST',
			url: 'AJAX_BO_LoadCatProducts.cfm',
			data: {"id":a},
			beforeSend: function(){
				if (display == "block") {
					selector.stop().fadeOut();
				}
			},
			success:function(data){
				selector.html(data).stop().fadeIn();
			}
		});
	}
	$.fn.BOAddProductForm=function(a,b) {
		var selector=$(this);
		$.ajax({
			type: 'POST',
			url: 'AJAX_BO_AddProduct.cfm',
			data: {"catID":a,"file":b},
			success:function(data){
				selector.html(data);
			}
		});
	}
	$.BOAddProduct=function(a,b) {
		$.ajax({
			type: 'POST',
			url: 'AJAX_AddProductAction.cfm',
			data: b.serialize(),
			success:function(data){
				$('#bocontent').BOLoadCatProducts(a);
			}
		});
	}
})(jQuery);