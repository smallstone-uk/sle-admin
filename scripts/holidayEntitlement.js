// JavaScript Documentvar 

entitlement = 5.6;

function calculateHoliday() {
	var s = parseDate($('#holiday-calculator-start-date').val());
	var e = parseDate($('#holiday-calculator-end-date').val());

	if (s&&e) {
		if (validatePeriod(s,e)) {
			updateEntitlementWeeks(s,e);
			updateEntitlementDays(s,e);
			updateDaysInLieu(s,e);
			updatePay(s,e);
		}
	}
}
function updateEntitlementWeeks(s,e) {
	$('#holiday-calculator-entitlement-weeks').val(getWeeks(s,e));
}
function getWeeks(s,e) {
	var weeks = nxParseFloat((entitlement/52)*nxParseFloat((e-s)/604800000),2);

	return weeks
}
function updateEntitlementDays(s,e) {
	var days = getDays(s,e);

	if (!isNaN(days)) {
		$('#holiday-calculator-entitlement-days').val(days);
		$('#holiday-calculator-entitlement-lieu-days').val(days);
		$('#holiday-calculator-entitlement-half-days').val(nxRoundUpHalfDay(days));
	}
}
function getDays(s,e) {
	var days = nxParseFloat(getWeeks(s,e)*$('#holiday-calculator-days-per-week').val(),2);

	return days;
}
function updateDaysInLieu(s,e) {
	removeError('#holiday-calculator-days-taken');
	var taken = $('#holiday-calculator-days-taken').val();
	var days;

	if (taken) {
		if (!isNaN(taken)) {
			days = nxParseFloat(getDays(s,e) - taken,2);
			if (days>=0) {
				$('#holiday-calculator-days-in-lieu').val(days);
			} else {
				generateError('#holiday-calculator-days-taken','The number of holiday days taken has exceeded the number of days due.');
				$('#holiday-calculator-days-in-lieu').val(0);
				$('#holiday-calculator-additional-pay').val(0);
			}	
		} else {
			generateError('#holiday-calculator-days-taken','Must be a valid number format.');
			$('#holiday-calculator-days-in-lieu').val(0);
			$('#holiday-calculator-additional-pay').val(0);
		}
	}
}
function updatePay(s,e) {
	var taken = $('#holiday-calculator-days-taken').val();
	var rate = $('#holiday-calculator-daily-rate').val();
	var days;

	if (taken&&rate) {
		if (!isNaN(taken)) {
			if (!isNaN(rate)) {
				days = nxParseFloat(getDays(s,e) - taken,2);
				removeError('#holiday-calculator-daily-rate');
				if (days>=0) {
					$('#holiday-calculator-additional-pay').val(nxParseFloat(days*rate,2));
				} else {
					$('#holiday-calculator-additional-pay').val(0);
				}
			} else {
				generateError('#holiday-calculator-daily-rate','Must be a valid number format.');
				$('#holiday-calculator-additional-pay').val(0);
			}
		}
	}
}
function nxParseFloat(n,p) {
	n = parseFloat(n).toFixed(p);

	return n
}
function nxRoundUpHalfDay(n) {

	n = nxParseFloat(Math.ceil(n / 0.5) * 0.5,1);

	return n;
}
function validatePeriod(s,e) {
	var good = false;
	if (s<e) {
		var inYear = e-s;
		if (inYear<31556952000) {
			removeError($('#holiday-calculator-end-date'));
			good = true;
		} else {
			generateError($('#holiday-calculator-end-date'),'The contract period specified must be less than a year.');
			$('#holiday-calculator-days-in-lieu').val(0);
			$('#holiday-calculator-additional-pay').val(0);
			$('#holiday-calculator-entitlement-days').val(0);
			$('#holiday-calculator-entitlement-lieu-days').val(0);
			$('#holiday-calculator-entitlement-half-days').val(0);
			$('#holiday-calculator-entitlement-weeks').val(0);
		}
	} else {
		generateError($('#holiday-calculator-end-date'),'End date of contract must be after the start date.');
		$('#holiday-calculator-days-in-lieu').val(0);
		$('#holiday-calculator-additional-pay').val(0);
		$('#holiday-calculator-entitlement-days').val(0);
		$('#holiday-calculator-entitlement-lieu-days').val(0);
		$('#holiday-calculator-entitlement-half-days').val(0);
		$('#holiday-calculator-entitlement-weeks').val(0);
	}
	return good;
}
function parseDate(d) {
	var din = d.split('/');

	if (din.length==3) {
		return new Date(din[2], din[1], din[0]);
	} else {
		return false;
	}
}
function generateError(obj,msg) {
	removeError($(obj),msg);
	if ($(obj).parents('.field').find('span.error[data-msg="' + msg +'"]').length==0) {
		var error = $('<span class="error" data-msg="' + msg + '">' + msg + '</span>');
		error.hide();
		$(obj).parents('.field').append($(error));
		error.slideDown();
	}
}
function removeError(obj,msg) {
	$(obj).parents('.field').find('span.error').not('span.error[data-msg="' + msg +'"]').slideUp('fast',function() {$(this).remove()});
}


$(document).ready(function() {
	$('#holiday-calculator-start-date, #holiday-calculator-end-date').datepicker({
		dateFormat: 'dd/mm/yy'
	});
	$('#holiday-calculator-annual-entitlement').val(entitlement + ' weeks');
	$('#holiday-calculator input').change(function() {
		calculateHoliday();
	});
	$('#holiday-calculator input[readonly="readonly"]').focus(function() {
		$(this).nextInDOM('input').focus();
	});
	var $button = $('<button id="recalc">Recalculate</button>');
	$($button).click(function(e){
		calculateHoliday();		
		e.preventDefault();
	})
	$('#holiday-calculator p.submit').prepend($button);
});