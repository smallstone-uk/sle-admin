;(function($) {
	setVars = function() {
		recordID = $('#PRHRecordID').val();
		grossTotal = $('.PRHIField_GT').val();
		paye = $('.PRHIField_PAYE').val();
		ni = $('.PRHIField_NI').val();
		np = $('.PRHIField_NP').val();
	}
	
	$.messageBox = function(a, b, c) {
		var _params = {
			id: "sle-message-box",
			width: 250,
			height: 30,
			easing: 200,
			delay: 2000
		};
		$('#' + _params.id).each(function(index, element) {
			$(element).remove();
		});
		var _style = "display: none;position: fixed;width:" + _params.width + "px;height: 0px;background: rgba(139, 173, 52, 0.75);text-align: center;line-height: 0px;font-size: 14px;color: #FFF;z-index: 0;top: 98px;";
		$('body').prepend("<div id='" + _params.id + "' style='" + _style + "'></div>");
		var _box = $('#' + _params.id);
		if (b == "error")
			_box.css("background", "rgba(173, 52, 52, 0.75)");
		_box
			.html(a)
			.fadeIn(_params.easing)
			.css("left", Math.max(0, (($(window).width() - _box.outerWidth()) / 2)))
			.animate({"height": _params.height, "line-height": _params.height + "px"}, _params.easing);
		setTimeout(function(){
			_box.animate({
				"height": "0px",
				"line-height": "0px"
			}, _params.easing, 0, function(){
				_box.remove();
				if (typeof c == "function")
					c();
			});
		}, _params.delay);
	}
		   
	toJSON = function(arr) {
		return JSON.stringify(arr);
	}
		   
	serializeFields = function(prefixArr, recordID, empID, prWeek, grossTotal, paye, ni, np) {		
		var headers = [];
		
		totalHours = function() {
			var hours = 0;
			$('.PRHIField').each(function(index, element) {
				if (parseFloat($(element).val()) > 0) {
					hours = hours + parseFloat( $(element).val() );
				}
			});
			return hours;
		}
		
		var prTotalHours = parseFloat( totalHours() );
		
		for (var i = 0; i < prefixArr.length; i++) {
			headers.push({
				type: prefixArr[i],
				cells: [],
				gross: 0
			});
		}
		
		for (var i = 0; i < headers.length; i++) {
			var row = $('#' + headers[i].type + 'Row');
			var gross = $('#' + headers[i].type + 'Total').html();
			headers[i].gross = gross;
			row.find('.PRHIDay[data-prefix="' + headers[i].type + '"]').each(function(index, element) {
				headers[i].cells.push({
					day: $(element).attr("data-dayStr"),
					hours: $(element).find('.PRHIField').val(),
					rate: $(element).attr("data-rate")
				});
			});
		}
		
		$.ajax({
			type: "POST",
			url: "ajax/AJAX_savePayrollRecord.cfm",
			data: {
				"headers": toJSON(headers),
				"recID": recordID,
				"empID": empID,
				"prWeek": prWeek,
				"grossTotal": grossTotal,
				"paye": paye,
				"ni": ni,
				"np": np,
				"totalHours": prTotalHours
			},
			beforeSend: function() {},
			success: function(data) {
				$.messageBox("Saved", "success");
			}
		});
	}
		   
	rowTotal = function(prefixArr) {
		for (var i = 0; i < prefixArr.length; i++) {
			var total = 0;
			var row = $('#' + prefixArr[i] + 'Row');
			row.find('.PRHIDay[data-prefix="' + prefixArr[i] + '"]').each(function(index, element) {
				var rate = $(element).attr("data-rate"),
					hours = $(element).find('.PRHIField').val();
				total = total + ( rate * hours );
			});
			var result = total.toFixed(2);
			row.find('#' + prefixArr[i] + 'Total').html(result);
		}
	}
		   
	calculateGrossTotal = function(prefixArr) {
		var total = 0;
		var ni = parseFloat($('.PRHIField_NI').val());
		var paye = parseFloat($('.PRHIField_PAYE').val());
		for (var i = 0; i < prefixArr.length; i++) {
			var prefTotal = parseFloat($('#' + prefixArr[i] + 'Total').html());
			total = total + prefTotal;
		}
		var result = (total - (ni + paye)).toFixed(2);
		$('.PRHIField_GT').val(total.toFixed(2));
		$('.PRHIField_NP').val(result);
	}
	
	$.bindPayrollControls = function() {
		var employee, week;
		loadRecord = function() {
			if (employee != null && week != null) {
				$.ajax({
					type: "POST",
					url: "ajax/AJAX_loadPayrollRecord.cfm",
					data: {
						"employee": employee,
						"prWeek": week
					},
					beforeSend: function() {
						$('#loading').html("Loading...");
					},
					success: function(data) {
						$('#loading').html("");
						$('#PRContent').html(data);
					}
				});
			}
		}
		$('#PRHFFName').bind("change", function(event) {
			$('#PRHName').attr("data-employee", $(this).val());
			employee = $(this).val();
			loadRecord();
		});
				
		$('.datepicker').datepicker({
			dateFormat: "yy-mm-dd",
			changeMonth: true,
			changeYear: true,
			showButtonPanel: true,
			onClose: function() {
				week = $(this).val();
				loadRecord();
			}
		});
		
		employee = $('#PRHFFName').val();
		week = $('#PRHFFWEDate').val();
		loadRecord();
	}
})(jQuery);