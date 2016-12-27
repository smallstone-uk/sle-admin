; (function($) {
	window.barcode = "";
	String.prototype.containsSpace = function() {
		return /[\s]/.test(this);
	}
	String.prototype.isSymbol = function() {
		return /[$-/:-?{-~!""^_`\[\]]/.test(this);
	}
	String.prototype.isNumber = function() {
		return /^([-\d]|\.)+$/.test(this);
	}
	String.prototype.isBoolean = function() {
		if (this == "true" || this == "false") return true; else return false;
	}
	String.prototype.isEncoded = function() {
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
				result[element[0].trim()] = value;
			}
		}
		return result;
	}
	getDataAttributes = function(node, type, extended) {
		var d = {}, re_dataAttr = /^data\-(.+)$/;
		$.each(node.get(0).attributes, function(index, attr) {
			if (re_dataAttr.test(attr.nodeName)) {
				var key = attr.nodeName.match(re_dataAttr)[1];
				var isNum = attr.value.isNumber();
				var isBool = attr.value.isBoolean();
				if (typeof type != "undefined" && type == "plain") {
					var value = attr.value;
				} else {
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
				}
				d[key] = value;
			}
		});
		if (typeof type == "undefined") {
			return d;
		} else {
			switch (type) {
				case "html":
					var retStr = "";
					for (var k in d) {
						var itStr = " data-" + k + "='" + d[k] + "'";
						retStr += itStr;
					}
					return retStr;
					break;
				case "plain":
					if (typeof extended == "object") {
						var object = $.extend(d, extended);
						return object;
					} else {
						return d;
					}
					break;
			}
		}
	}
	$.fn.center = function(a, b) {
		var caller = $(this);
		caller.css("position", b || "absolute");
		switch (a || "both") {
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
	$.fn.serializeObject = function() {
		var o = {};
		var a = this.serializeArray();
		$.each(a, function() {
			if (o[this.name] !== undefined) {
				if (!o[this.name].push) {
					o[this.name] = [o[this.name]];
				}
				o[this.name].push(this.value || '');
			} else {
				o[this.name] = this.value || '';
			}
		});
		return o;
	};
	$.productSelect = function(params) {
		var delay = 250;
		$('.product_selector, .light_dim').remove();
		$.ajax({
			type: "POST",
			url: "ajax/deals/loadProductSelect.cfm",
			data: { "params": JSON.stringify(params) },
			beforeSend: function() {
				$('.product_selector, .light_dim').remove();
			},
			success: function(data) {
				$('body').prepend("<div class='light_dim'></div><div class='product_selector'><div class='inner'>" + data + "</div></div>");
				$('.product_selector').center("both", "fixed");
				window["productSelectComplete"] = function(arr) {
					$('.product_selector, .light_dim').remove();
					if (typeof params.callback == "function") params.callback(arr);
					window.productSelectComplete = null;
				}
				$('.light_dim').click(function(event) {
					$('.product_selector, .light_dim').remove();
					event.preventDefault();
				});
			}
		});
		return this;
	}
	$.fn.clickAjax = function(params) {
		$(this).bind("click", function(event) {
			var caller = $(this);
			$.extend(params.data, getDataAttributes(caller, "plain"));
			$.ajax(params);
			event.preventDefault();
		});
	}
	$.scanner = function(a, b) {
		try {
			if (a.keyCode == 13) {
				if (window.barcode.length >= 8 && window.barcode.length <= 14 && typeof b == "function") {
					var _b = window.barcode;
					b(_b);
				} else {
					// console.log("else: " + window.barcode);
				}
				window.barcode = "";
			} else {
				// window.barcode += (String.fromCharCode(a.keyCode) + "");
				window.barcode += (String.fromCharCode(a.keyCode) + "");
				// console.log(String.fromCharCode(a.keyCode));
			}
		} catch (error) {
			console.log(error);
		}
	}
	$.scanBarcode = function(params) {
		if (typeof params.preinit == "function") params.preinit();
		$(document).bind("keydown.scanBarcodeEvent", function(event) {
			try {
				if (!($('input').is(":focus"))) {
					$.scanner(event, function(barcode) {
						if (typeof params.callback == "function") params.callback(barcode);
						if (params.unbindOnCallback || false) $(document).unbind("keydown.scanBarcodeEvent");
					});
				} else {
					window.barcode = "";
				}
			} catch (error) {
				console.log(error);
			}
		});
		if (typeof params.postinit == "function") params.postinit();
	}
})(jQuery);