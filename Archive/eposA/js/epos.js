window.Barcode="";
window.keypad="";
window.keypadDecimal="";
window.touchtime=0;
window.touchhold=false;
window.cashonlyError=false;

;(function($) {
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
	$.fn.validator = function(params) {
		var error = 0;
		applyTooltip = function(obj, hint) {
			console.log(hint);
			$('input[type="submit"], input[type="button"]').prop('disabled', true);
		}
		clear = function() {
			if (error === 0) $('input[type="submit"], input[type="button"]').prop('disabled', false);
		}
		$(this).bind("keyup", function(event) {
			var input = $(this);
			var str = input.val();
			if (params.length) {
				if (str.length < params.length[0]) {
					error++;
					applyTooltip(input, "You must enter more than " + params.length[0] + " characters");
				} else if (str.length > params.length[1]) {
					error++;
					applyTooltip(input, "You have exceeded the maximum length of " + params.length[1] + " characters");
				} else {
					error--;
					clear();
				}
			}
			if (params.spaces) {
				switch (params.spaces)
				{
					case "single":
						if ( (str.match(/[\s]{2,}/ig)).length > 0 ) {
							error++;
							applyTooltip(input, "You can't have multiple grouped spaces");
						} else {
							error--;
						}
						break;
					case "none":
						if ( (str.match(/[\s]/ig)).length > 0 ) {
							error++;
							applyTooltip(input, "You can't have spaces");
						} else {
							error--;
						}
						break;
				}
				clear();
			}
			if (params.chars) {
				switch (params.chars)
				{
					case "numbers":
						if ( (str.match(/[^\d]/ig)).length > 0 ) {
							error++;
							applyTooltip(input, "You can only use numbers here");
						} else {
							error--;
						}
						break;
					case "letters":
						if ( (str.match(/[^\D]/ig)).length > 0 ) {
							error++;
							applyTooltip(input, "You can only use letters and symbols here");
						} else {
							error--;
						}
						break;
				}
				clear();
			}
		});
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
	$.fn.center = function(a) {
		var caller = $(this);
		
		caller.css("position","absolute");
		
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
	$.virtualKeyboard = function(a, b) {
		var presetText = (typeof a != "undefined" && typeof a != "function") ? a : "";
		$('.virtual_numpad').animate({
			"bottom": "-1000px"
		}, 500, "easeInOutCubic");
		$('.vk_text').val(presetText).focus();
		$('body').prepend("<div class='dim'></div>");
		$('.dim').fadeIn(500);
		$('.virtual_keyboard').animate({
			"bottom": "1%"
		}, 500, "easeInOutCubic");
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
	}
	$.virtualNumpad = function(a, b, c) {
		var presetText = (typeof a != "undefined" && typeof a != "function") ? a : "";
		$('.virtual_keyboard').animate({
			"bottom": "-1000px"
		}, 500, "easeInOutCubic");
		$('.vkn_text').val(presetText).focus();
		$('body').prepend("<div class='dim'></div>");
		$('.dim').fadeIn(500);
		$('.virtual_numpad').animate({
			"bottom": "1%"
		}, 500, "easeInOutCubic");
		if (typeof c != "undefined") {
			window.vkn_allowDecimal = false;
		} else {
			window.vkn_allowDecimal = true;
		}
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
	}
	$.fn.touchHold = function(a) {
		var caller = $(this), width = 400, delay = 500, activeColour = "#C00 !important";
		
		if ($.contains(document, caller[0])) {
			caller.on("mousedown", function() {
				var me = $(this);
				window.touchtime = setTimeout(function() {
					window.touchhold = true;
					
					window.touchHoldAction = function(index) {
						a[index].action(attributes, me);
						$('.touch_menu').remove();
					}
					
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
	$.LoadProduct=function(a,b,c,d,e) {
		if (typeof e == "undefined" && e == "0") {
			var qty=1;
		} else {
			var qty=e;
		}
		$.ajax({
			type: 'POST',
			url: 'AJAX_LoadProduct.cfm',
			data: {"barcode":a,"prodID":b,"manualprice":c,"type":d,"qty":qty},
			beforeSend: function(){
				$('#tempscript').remove();
			},
			success:function(data){
				$('#basket').html(data);
				$('#basket').LoadBasket();
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
				if (result.error1 == "true") {
					$.messageBox("CASH ONLY items must be paid by cash or cash back.","error");
					window.cashonlyError=true;
				} else {
					$('#basket').LoadBasket(Number(result.changedue));
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
					$.LoadProduct(a,Number(result.id),0,result.type,1);
				}
			}
		});
	}
	$.fn.AddProductForm=function(a,b) {
		var selector=$(this);
		$.ajax({
			type: 'POST',
			url: 'AJAX_AddProduct.cfm',
			data: {"catID":a,"file":b},
			success:function(data){
				selector.html(data);
			}
		});
	}
	$.AddProduct=function(a,b,c) {
		$.ajax({
			type: 'POST',
			url: 'AJAX_AddProductAction.cfm',
			data: c.serialize(),
			success:function(data){
				$('#overlay').LoadCatProducts(a,b);
			}
		});
	}
	$.Scanner=function(a) {
		var code=window.Barcode;
		if (a.keyCode == 13) {
			if (code.length >= 8 & code.length <= 14) {
				console.log(window.Barcode);
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
	$.messageBox = function(a, b, c) {
		var _params = {
			id: "sle-message-box",
			height: 40,
			easing: 100,
			delay: 8000
		};
		$(document).unbind(".msgBoxEvents");
		$('#' + _params.id).each(function(index, element) {
			$(element).remove();
		});
		$('body').prepend("<div id='" + _params.id + "' class='msgbox'></div>");
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
			if (typeof params.cancel != "undefined" && typeof params.cancel == "function") params.cancel();
		});
	}
})(jQuery);
