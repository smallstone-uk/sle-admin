;(function($) {
	window.epos_frame = {
		grocer_int: null,
		news_int: null
	};
	
	$.fn.grocerStories = function() {
		var caller = this;
		var delay = 10000;
		clearInterval(window.epos_frame.grocer_int);
		
		loadStory = function() {
			$.ajax({
				type: "GET",
				url: "ajax/loadGrocerStory.cfm",
				success: function(data) {
					var result = data.toJava();
					caller.html('<div><p>' + result.content + '</p></div>');
				}
			});
		}
		
		loadStory();
		
		window.epos_frame.grocer_int = setInterval(function() {
			loadStory();
		}, delay);
	}
	$.fn.newsStories = function() {
		var caller = this;
		var delay = 10000;
		clearInterval(window.epos_frame.news_int);
		
		loadStory = function() {
			$.ajax({
				type: "GET",
				url: "ajax/loadNewsStory.cfm",
				success: function(data) {
					var result = data.toJava();
					caller.html('<div><p>' + result.content + '</p></div>');
				}
			});
		}
		
		loadStory();
		
		window.epos_frame.news_int = setInterval(function() {
			loadStory();
		}, delay);
	}
	$.fn.barcodeBox = function(callback) {
		var selector = $(this);
		
		return selector.each(function(i, e) {
			var caller = $(e);
			var scanning = false;
			
			caller.bind("click", function(event) {
				scanning = true;
				caller.html("Waiting for barcode");
				$(document).bind("keypress", function(e) {
					if (scanning) {
						$.scanner(e, function(barcode) {
							caller.html(barcode);
							scanning = false;
							if (typeof callback == "function") callback(barcode);
							caller.clearQueue().stop().finish();
						});
					}
				});
				event.preventDefault();
			});
		});
	}
	$.fn.booleanResponse = function(file, cons) {
		var selector = $(this);
		var conswitch = cons || true;
		
		return selector.each(function(i, e) {
			var caller = $(e);
			
			caller.bind("focus", function(event) {
				if (caller.val().length > 0 && conswitch) {
					$.ajax({
						type: "POST",
						url: file,
						data: {"value": caller.val()},
						success: function(data) {
							var response = ( data.trim() == "true" ) ? true : false;
							if (response) {
								caller.addClass("boolean_response_true");
							} else {
								caller.removeClass("boolean_response_true");
							}
						}
					});
				} else {
					caller.removeClass("boolean_response_true");
				}
			});
		});
	}
	$.openTill = function() {
		$.ajax({
			type: "GET",
			url: "ajax/openTill.cfm",
			success: function(data) {
				$('.printable').html(data);
			}
		});
	}
	$.printReceipt = function(tranID) {
		$.ajax({
			type: "POST",
			url: "ajax/printReceipt.cfm",
			data: {"tranID": tranID},
			success: function(data) {
				$('.printable').html(data);
			}
		});
	}
	$.calendar = function(year, month, callback) {
		$.ajax({
			type: "POST",
			url: "ajax/loadCalendar.cfm",
			data: {
				"cyear": year,
				"cmonth": month
			},
			success: function(data) {
				if (typeof callback == "function") callback(data);
			}
		});
	}
	$.fullscreenPopup = function(content) {
		$('.fullscreen_popup_box').remove();
		$('body').prepend("<div class='fullscreen_popup_box'>" + content + "</div>");
		
		var box = $('.fullscreen_popup_box');
		
		var counter = 0;
		var grow = null;
		grow = setInterval(function() {
			counter += 0.1;
			box.css({
				"transform": "scale3d(" + counter + ", " + counter + ", " + counter + ")",
				"opacity": counter
			});
			if (counter >= 1) {
				clearInterval(grow);
				box.css("transform", "scale3d(1, 1, 1)");
			}
		}, 15);
	}
	$.popup = function(content, confirmation) {
		$('.popup_box, .dim').remove();
		$('body').prepend("<div class='dim'></div><div class='popup_box'>" + content + "</div>");
		
		var box = $('.popup_box');
		var dim = $('.dim');
		box.center();
		dim.fadeIn();
		
		var counter = 0;
		var grow = null;
		grow = setInterval(function() {
			counter += 0.1;
			box.css({
				"transform": "scale3d(" + counter + ", " + counter + ", " + counter + ")",
				"opacity": counter
			});
			if (counter >= 1) {
				clearInterval(grow);
				box.css("transform", "scale3d(1, 1, 1)");
			}
		}, 15);
		
		box.htmlClick(function() {
			if (typeof confirmation == "undefined" || !confirmation) {
				dim.fadeOut();
				var counter = 1;
				var shrink = null;
				shrink = setInterval(function() {
					counter -= 0.1;
					box.css({
						"transform": "scale3d(" + counter + ", " + counter + ", " + counter + ")",
						"opacity": counter
					});
					if (counter <= 0) {
						clearInterval(shrink);
						box.remove();
					}
				}, 15);
			}
		});
	}
	$.bigDatePicker = function() {
		$('.big_datepicker_backdrop').remove();
		$('body').prepend("<div class='big_datepicker_backdrop'><div class='bdp_inner'></div></div>");
		
		var now = new Date();
		var today = {
			day: now.getDate(),
			month: now.getMonth() + 1,
			year: now.getFullYear()
		};
		
		var selected = {
			day: today.day,
			month: today.month,
			year: today.year
		};
		
		highlightSelected = function() {
			var scope = $('.bdp_scope');
			var selDay = $('.bdp_days').find('li[data-value="' + selected.day + '"]');
			var selMonth = $('.bdp_months').find('li[data-value="' + selected.month + '"]');
			var selYear = $('.bdp_years').find('li[data-value="' + selected.year + '"]');
			
			var frameHeight = $(window).innerHeight();
			var scopeTop = scope.offset().top;
			
			// Days
			$('.bdp_days').find('li').removeClass("bdp_selected");
			$('.bdp_days').find('li[data-value="' + selected.day + '"]').addClass("bdp_selected");
			var selDayTop = selDay.offset().top;
			var selDayHeight = selDay.height();
			var listBottom = frameHeight - (selDayTop + selDayHeight);
			var difference = ((frameHeight / 2) - listBottom - (selDayHeight / 2)) * -1;
			$('.bdp_days').css("top", difference);
			
			// Months
			$('.bdp_months').find('li').removeClass("bdp_selected");
			$('.bdp_months').find('li[data-value="' + selected.month + '"]').addClass("bdp_selected");
			var selMonthTop = selMonth.offset().top;
			var selMonthHeight = selMonth.height();
			var listBottom = frameHeight - (selMonthTop + selMonthHeight);
			var difference = ((frameHeight / 2) - listBottom - (selMonthHeight / 2)) * -1;
			$('.bdp_months').css("top", difference);
			
			// Years
			$('.bdp_years').find('li').removeClass("bdp_selected");
			$('.bdp_years').find('li[data-value="' + selected.year + '"]').addClass("bdp_selected");
			var selYearTop = selYear.offset().top;
			var selYearHeight = selYear.height();
			var listBottom = frameHeight - (selYearTop + selYearHeight);
			var difference = ((frameHeight / 2) - listBottom - (selYearHeight / 2)) * -1;
			$('.bdp_years').css("top", difference);
		}
		
		daysInMonth = function(month, year) {
			return new Date(year, month, 0).getDate();
		}
		
		getDays = function() {
			var result = "";
			var end = daysInMonth(selected.month, selected.year);
			
			for (var i = 1; i < end; i++) {
				result += "<li data-part='day' data-value='" + i + "'>" + zeroPad(i, 2) + "</li>";
			}
			
			return result;
		}
		
		getMonths = function() {
			var result = "";
			
			for (var i = 0; i < 11; i++) {
				result += "<li data-part='month' data-value='" + (i + 1) + "'>" + zeroPad( (i + 1), 2 ) + "</li>";
			}
			
			return result;
		}
		
		getYears = function(a) {
			var result = "";
			var start = today.year - a;
			var end = today.year + a;
			
			for (var i = start; i < end; i++) {
				result += "<li data-part='year' data-value='" + i + "'>" + i + "</li>";
			}
			
			return result;
		}
		
		$('.big_datepicker_backdrop .bdp_inner').append("<ul class='bdp_days'>" + getDays() + "</ul>");
		$('.big_datepicker_backdrop .bdp_inner').append("<ul class='bdp_months'>" + getMonths() + "</ul>");
		$('.big_datepicker_backdrop .bdp_inner').append("<ul class='bdp_years'>" + getYears(10) + "</ul>");
		$('.big_datepicker_backdrop .bdp_inner').center();
		
		$('body').prepend("<div class='bdp_scope'></div>");
		$('.bdp_scope').center("top");
		
		highlightSelected();
		
		var mouseDown = false;
		var mouseY = 0;
		
		$(document).bind("mousedown", function(event) {
			mouseDown = true;
			mouseY = event.pageY;
		});
		
		$(document).bind("mouseup", function(event) {
			mouseDown = false;
			mouseY = 0;
		});
		
		$(document).bind("mousemove", function(event) {
			if (mouseDown) {
				var target = $(event.target);
				
				if ( target.is($('.bdp_days')) || target.is($('.bdp_days').find('*')) ) {
					var curMouseY = event.pageY;
					var distance = curMouseY - mouseY;
					var winHeight = $(window).innerHeight();
					var winScrollTop = $(window).scrollTop();
					var curHeight = $('.bdp_days').height();
					var curTop = $('.bdp_days').css("top").replace("px", "");
					var curBottom = winHeight - curTop - curHeight;
					var excess = $(window).innerHeight() - curMouseY;
					var newTop = curTop - (distance * -1);
					$('.bdp_days').css("top", newTop);
					
					$('.bdp_days').find('li').each(function(i, e) {
						console.log($(e).offset().top);
						if ( $(e).offset().top <= 0 ) {
							$(e).appendTo($('.bdp_days'));
						} else if ( $(e).offset().top >= winHeight ) {
							$(e).prependTo($('.bdp_days'));
						}
					});
					
					/*if (newTop < -25) {
						console.log("Point A");
						if (curBottom < -25) {
							console.log("Point B");
							$('.bdp_days').css("top", newTop)
						}
					} else if (curBottom < -25) {
						console.log("Point C");
						if (newTop < -25) {
							console.log("Point D");
							$('.bdp_days').css("top", newTop)
						}
					}*/
					
					mouseY = curMouseY;
				}
			}
		});
	}
	zeroPad = function(num, places) {
		var zero = places - num.toString().length + 1;
		return Array(+(zero > 0 && zero)).join("0") + num;
	}
	componentToHex = function(c) {
		var hex = c.toString(16);
		return hex.length == 1 ? "0" + hex : hex;
	}
	
	rgbToHex = function(r, g, b) {
		return "#" + componentToHex(r) + componentToHex(g) + componentToHex(b);
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
	$.confirmation = function(message, callback) {
		$('.confirm_box').remove();
		$('.dim').remove();
		
		var useMessage = (typeof message == "string") ? message : "Are you sure?";
		
		window.confirmationCallback = function(a) {
			$('.confirm_box').fadeOut(200, function() {$('.confirm_box').remove();});
			$('.dim').fadeOut(200, function() {$('.dim').remove();});
			if (a == 1 && typeof message == "function") {
				message();
			} else if (a == 1 && typeof callback == "function") {
				callback();
			}
		}
		
		$('body').prepend("<div class='dim'></div>");
		$('body').prepend("<div class='confirm_box'><div class='confirm_box_inner'><p>" + useMessage + "</p><button onclick='window.confirmationCallback(1)' style='float:left;width:290px;'>Yes</button><button onclick='window.confirmationCallback(2)' style='width:290px;'>No</button></div></div>");
		
		$('.confirm_box').center("top");
		$('.confirm_box').fadeIn(200);
		$('.dim').fadeIn(200);
	}
	$.addCharge = function(params) {
		$.ajax({
			type: "POST",
			url: "ajax/addCharge.cfm",
			data: params,
			success: function(data) {
				$.loadBasket();
			}
		});
	}
	$.addDiscount = function(params) {
		$.ajax({
			type: "POST",
			url: "ajax/addDiscount.cfm",
			data: params,
			success: function(data) {
				$.loadBasket();
			}
		});
	}
	$.addPayment = function(params) {
		$.ajax({
			type: "POST",
			url: "ajax/addPayment.cfm",
			data: params,
			success: function(data) {
				$.msgBox("&pound;" + params.value + " paid by " + params.type.toUpperCase());
				$.loadBasket();
			}
		});
	}
	$.fn.loadPayments = function() {
		var caller = $(this);
		$.ajax({
			type: "GET",
			url: "ajax/loadPayments.cfm",
			success: function(data) {
				caller.html(data);
			}
		});
	}
	$.fn.buttonSelect = function(a) {
		var caller = $(this);
		caller.find('li').each(function(i, e) {
			var selected = $(this).data("selected");
			if (typeof selected != "undefined") {
				caller.find('li').removeClass("active_button");
				$(a).val( $(e).html().trim() );
				$(e).addClass("active_button");
			}
		});
		caller.find('li').bind("click", function(event) {
			caller.find('li').removeClass("active_button");
			$(a).val( $(this).html().trim() );
			$(this).addClass("active_button");
		});
	}
	$.fn.bigSelect = function(params) {
		var host = $(this);
		host.each(function(i, e) {
			var caller = $(e), htmlItems = "", slideSpeed = 250, itemCount = 0, itemHeight = (typeof params.height == "undefined") ? 60 : params.height, firstItem = "";
			var style = (typeof caller.data("style") != "undefined") ? caller.data("style") : "";
			
			slideHide = function(a) {
				$('.bsw_list_activeItem[data-index="' + a + '"]').slideDown(slideSpeed);
				caller.next('.bigselect_wrapper[data-index="' + a + '"]').find('.bsw_list[data-index="' + a + '"]').animate({height: itemHeight}, slideSpeed, "easeInOutCubic");
			}
			
			slideShow = function(a) {
				$('.bsw_list_activeItem[data-index="' + a + '"]').slideUp(slideSpeed);
				caller.next('.bigselect_wrapper[data-index="' + a + '"]').find('.bsw_list[data-index="' + a + '"]').animate({height: (itemCount * itemHeight)}, slideSpeed, "easeInOutCubic");
			}
			
			toggleList = function(a) {
				if ($('.bsw_list[data-index="' + a + '"]').css("height") != (itemHeight + "px")) slideHide(a); else slideShow(a);
			}
			
			highlightActive = function(a) {
				var active = $('.bsw_list_activeItem[data-index="' + a + '"]').html();
				caller.next('.bigselect_wrapper[data-index="' + a + '"]').find('.bsw_list_item[data-index="' + a + '"]').each(function(i, el) {
					$(el).removeClass("bsw_list_item_highlight");
					if ( $(el).html() == active ) $(el).addClass("bsw_list_item_highlight");
				});
			}
			
			caller.find('option').each(function(index, option) {
				htmlItems += "<li class='bsw_list_item' data-index='" + i + "' data-value='" + $(this).attr("value") + "' style='height:" + itemHeight + "px;'>" + $(this).html() + "</li>";
				if (index == 0) firstItem = $(this).html();
				itemCount++;
			});
			
			var htmlOutput = "<div class='bigselect_wrapper' data-index='" + i + "' style='height:" + itemHeight + "px;" + style + "'><ul class='bsw_list' data-index='" + i + "' style='height:" + itemHeight + "px;" + style + "'><li class='bsw_list_activeItem' data-index='" + i + "' style='height:" + itemHeight + "px;'>" + firstItem + "</li>" + htmlItems + "</ul></div>";
			
			caller.after(htmlOutput);
			caller.hide();
			
			$(document).on("click", ".bigselect_wrapper .bsw_list .bsw_list_item", function(event) {
				$(this).parent('ul').find('.bsw_list_activeItem').html( $(this).html() );
				var index = $(this).parents('.bigselect_wrapper').data("index");
				if (typeof params.callback == "function") params.callback($(this).data("value"));
				highlightActive(index);
			});
			
			caller.next('.bigselect_wrapper').find('.bsw_list').bind("click", function(event) {
				var index = $(this).parents('.bigselect_wrapper').data("index");
				toggleList(index);
				highlightActive(index);
			});
			
			$('.bigselect_wrapper[data-index="' + i + '"]').htmlClick(function() {
				slideHide(i);
				highlightActive(i);
			});
		});
	}
	$.openCategory = function(catID) {
		$.ajax({
			type: "POST",
			url: "ajax/productsByCategory.cfm",
			data: {"catID": catID},
			success: function(data) {
				
			}
		});
	}
	String.prototype.containsSpace = function(){
		return /[\s]/.test(this);
	}
	String.prototype.isSymbol = function() {
		return /[$-/:-?{-~!""^_`\[\]]/.test(this);
	}
	String.prototype.isNumber = function() {
		return /^(\d|\.)+$/.test(this);
	}
	String.prototype.isBoolean = function() {
		if (this == "true" || this == "false") return true; else return false;
	}
	String.prototype.isEncoded = function() {
		console.log(decodeURIComponent(this));
		return decodeURIComponent(this) !== this;
	}
	String.prototype.toJava = function() {
		var a = this;
		var result = {};
		var str = a.trim().replace(/\t/igm, "");
		var arr = str.split("@");
		for (var i = 0; i < arr.length; i++) {
			if (arr[i].length > 0) {
				var element = arr[i].split(":");
				var isNum = element[1].trim().isNumber();
				var isBool = element[1].trim().isBoolean();
				if (isNum) {
					var value = Number(element[1].trim());
				} else if (isBool) {
					if (element[1].trim() == "true") {
						var value = true;
					} else if (element[1].trim() == "false") {
						var value = false;
					}
				} else {
					var value = element[1].trim();
				}
				result[ element[0].trim() ] = value;
			}
		}
		return result;
	}
	getDataAttributes = function(node) {
		var d = {}, re_dataAttr = /^data\-(.+)$/;
		$.each(node.get(0).attributes, function(index, attr) {
			if (re_dataAttr.test(attr.nodeName)) {
				var key = attr.nodeName.match(re_dataAttr)[1];
				
				var isNum = attr.value.isNumber();
				var isBool = attr.value.isBoolean();
				if (isNum) {
					var value = Number(attr.value);
				} else if (isBool) {
					if (attr.value == "true") {
						var value = true;
					} else if (attr.value == "false") {
						var value = false;
					}
				} else {
					var value = attr.value;
				}
				
				d[key] = value;
			}
		});
		return d;
	}
	$.searchBarcode = function(barcode) {
		$.ajax({
			type: "POST",
			url: "ajax/searchBarcode.cfm",
			data: {"barcode": barcode},
			success: function(data) {
				var result = data.toJava();
				if (typeof result.prodid != "undefined") {
					var price = (Math.abs(result.encodedvalue) > 0) ? result.encodedvalue : result.prodourprice;
					if (result.minbalance <= result.basketBalance) {
						if (result.encodedvalue < 0) {
							$.addDiscount({
								title: result.prodtitle,
								value: result.encodedvalue,
								type: result.prodtitle.replace(/[\s]/ig, ""),
								unit: "pound",
								minbalance: result.minbalance
							});
						} else {
							$.addToBasket({
								id: result.prodid,
								title: result.prodtitle,
								type: result.type,
								price: price,
								cashonly: result.prodcashonly
							});
						}
					} else {
						$.msgBox("Balance must be greater than &pound;" + nf(result.minbalance, "str") + " for voucher to apply");
					}
				} else {
					$.msgBox("Product not found", "error");
				}
			}
		});
	}
	$.scanner = function(a, b) {
		var code = window.epos_frame.barcode;
		if (a.keyCode == 13) {
			if (code.length >= 8 & code.length <= 14) {
				if (typeof b == "undefined") {
					$.searchBarcode(window.epos_frame.barcode);
				} else if (typeof b == "function") {
					b(window.epos_frame.barcode);
				}
			}
			window.epos_frame.barcode = "";
		} else {
			var newStr = (code != "") ? code + String.fromCharCode(a.keyCode) : String.fromCharCode(a.keyCode);
			window.epos_frame.barcode = newStr;
		}
	}
	$.loadBasket = function(a) {
		$.ajax({
			type: "GET",
			url: "ajax/loadBasket.cfm",
			success: function(data) {
				$('.basket').html(data);
				if (typeof a == "function") a();
			}
		});
	}
	$.addToBasket = function(params) {
		$.ajax({
			type: "POST",
			url: "ajax/addToBasket.cfm",
			data: params,
			success: function(data) {
				$.loadBasket();
				// $.msgBox(params.title + " added to basket", "success");
			}
		});
	}
	$.tillNumpad = function(a) {
		$('.till_numpad span[data-method="enter"]').unbind("click");
		$('.till_numpad span[data-method="enter"]').bind("click", function(event) {
			var value = (Number($('.tn_value').html()) / 100).toFixed(2);
			if (typeof a == "function") a(value);
		});
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
	$.fn.center = function(a, b) {
		var caller = $(this);
		caller.css("position", b || "absolute");
		
		switch(a || "both")
		{
			case "top":
				caller.css("top", Math.max(0, (($(window).height() - caller.outerHeight()) / 2) + $(window).scrollTop()) + "px");
				break;
			case "left":
				caller.css("left", Math.max(0, (($(window).width() - caller.outerWidth()) / 2) + $(window).scrollLeft()) + "px");
				break;
			case "both":
				caller.css("top", Math.max(0, (($(window).height() - caller.outerHeight()) / 2) + $(window).scrollTop()) + "px");
				caller.css("left", Math.max(0, (($(window).width() - caller.outerWidth()) / 2) + $(window).scrollLeft()) + "px");
				break;
		}
	}
	cut = function(str, cutStart, cutEnd) {
	  return str.substr(0, cutStart) + str.substr(cutEnd + 1);
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
				if (typeof a == "function") a(target);
			}
		});
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
	$.fn.FCDatePicker = function(changed) {
		var iArray = [];
		var now = new Date();
		var placeholder = zeroPad(now.getDate(), 2) + "/" + zeroPad((now.getMonth() + 1), 2) + "/" + now.getFullYear();
		$(this).each(function(index, element) {
			var caller = $(element);
			iArray.push(index);
			caller
				.val(placeholder)
				.attr("data-dpindex", index)
			caller.bind("focus", function(event) {
				$('.FCDatePickerPopup').htmlClick(function() {
					$('.FCDatePickerPopup').hide();
				});
				$('.FCDatePickerPopup')
					.hide()
					.show()
					.attr("data-dpindex", $(this).attr("data-dpindex"));
				$('.FCDatePickerPopup').css({
					"left": caller.offset().left,
					"top": caller.offset().top + caller.height() + 5
				});
			});
		});
		setDatePickerValue = function(date, i) {
			var dateArr = date.split("/");
			$('.FCDatePicker[data-dpindex="' + iArray[i] + '"]').val( zeroPad(dateArr[2], 2) + "/" + zeroPad(dateArr[1], 2) + "/" + dateArr[0] );
			if (typeof changed == "function") {
				changed('.FCDatePicker[data-dpindex="' + iArray[i] + '"]');
			}
		}
		window.setDatePickerValue = setDatePickerValue;
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
	$.fn.touchHold = function(a) {
		var caller = $(this), width = 400, delay = 400;
		
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
						$('.touch_menu').css("left", (me.offset().left/* - menuHalfWidth + me.width() / 2*/));
					
						$('.touch_menu').show().animate({
							"width": me.width()/*width*/ + "px"
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
	$.msgBox = function(text, type, callback) {
		$('.message_box').remove();
		$('body').prepend("<div class='message_box'></div>");
		var settings = {delay: 3500, easing: 250};
		var box = $('.message_box');
		var background = (typeof type != "undefined" && type == "error") ? "rgba(173, 52, 52, 0.9)" : "rgba(139, 173, 52, 0.9)";
		
		box.html(text);
		box.css("background", background);
		box.animate({
			"left": 0
		}, settings.easing);
		
		setTimeout(function() {
			box.animate({
				"left": "-1000px"
			}, settings.easing, function() {
				if (typeof callback == "function") callback();
				box.remove();
			});
		}, settings.delay);
	}
})(jQuery);

// scrollTo Plugin
;(function(k){'use strict';k(['jquery'],function($){var j=$.scrollTo=function(a,b,c){return $(window).scrollTo(a,b,c)};j.defaults={axis:'xy',duration:parseFloat($.fn.jquery)>=1.3?0:1,limit:!0};j.window=function(a){return $(window)._scrollable()};$.fn._scrollable=function(){return this.map(function(){var a=this,isWin=!a.nodeName||$.inArray(a.nodeName.toLowerCase(),['iframe','#document','html','body'])!=-1;if(!isWin)return a;var b=(a.contentWindow||a).document||a.ownerDocument||a;return/webkit/i.test(navigator.userAgent)||b.compatMode=='BackCompat'?b.body:b.documentElement})};$.fn.scrollTo=function(f,g,h){if(typeof g=='object'){h=g;g=0}if(typeof h=='function')h={onAfter:h};if(f=='max')f=9e9;h=$.extend({},j.defaults,h);g=g||h.duration;h.queue=h.queue&&h.axis.length>1;if(h.queue)g/=2;h.offset=both(h.offset);h.over=both(h.over);return this._scrollable().each(function(){if(f==null)return;var d=this,$elem=$(d),targ=f,toff,attr={},win=$elem.is('html,body');switch(typeof targ){case'number':case'string':if(/^([+-]=?)?\d+(\.\d+)?(px|%)?$/.test(targ)){targ=both(targ);break}targ=win?$(targ):$(targ,this);if(!targ.length)return;case'object':if(targ.is||targ.style)toff=(targ=$(targ)).offset()}var e=$.isFunction(h.offset)&&h.offset(d,targ)||h.offset;$.each(h.axis.split(''),function(i,a){var b=a=='x'?'Left':'Top',pos=b.toLowerCase(),key='scroll'+b,old=d[key],max=j.max(d,a);if(toff){attr[key]=toff[pos]+(win?0:old-$elem.offset()[pos]);if(h.margin){attr[key]-=parseInt(targ.css('margin'+b))||0;attr[key]-=parseInt(targ.css('border'+b+'Width'))||0}attr[key]+=e[pos]||0;if(h.over[pos])attr[key]+=targ[a=='x'?'width':'height']()*h.over[pos]}else{var c=targ[pos];attr[key]=c.slice&&c.slice(-1)=='%'?parseFloat(c)/100*max:c}if(h.limit&&/^\d+$/.test(attr[key]))attr[key]=attr[key]<=0?0:Math.min(attr[key],max);if(!i&&h.queue){if(old!=attr[key])animate(h.onAfterFirst);delete attr[key]}});animate(h.onAfter);function animate(a){$elem.animate(attr,g,h.easing,a&&function(){a.call(this,targ,h)})}}).end()};j.max=function(a,b){var c=b=='x'?'Width':'Height',scroll='scroll'+c;if(!$(a).is('html,body'))return a[scroll]-$(a)[c.toLowerCase()]();var d='client'+c,html=a.ownerDocument.documentElement,body=a.ownerDocument.body;return Math.max(html[scroll],body[scroll])-Math.min(html[d],body[d])};function both(a){return $.isFunction(a)||typeof a=='object'?a:{top:a,left:a}}return j})}(typeof define==='function'&&define.amd?define:function(a,b){if(typeof module!=='undefined'&&module.exports){module.exports=b(require('jquery'))}else{b(jQuery)}}));