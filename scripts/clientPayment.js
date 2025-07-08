// JavaScript Document

var busy = false;

function checkTotal() {
//	var balance = Number($('#bfwd').val());
	var balance = 0;
	var tranAmount = 0;
	//console.log(' balance: ' + balance);
	// total transaction values if checked
	$('.allocs').each(function(index) {
		if ($(this).is(':checked')) {
			tranAmount = Number($(this).data('amount'));
		//	balance = balance + Math.round(tranAmount * 100);
			balance = balance + tranAmount;
			//console.log(' tranAmount:', tranAmount + ' balance: ' + balance);
		}
	});
//	balance = balance / 100;
	balance = balance.toFixed(2);
	$('#total').val(balance);
	//console.log(' balance: ' + balance);
	if (balance == 0.00)	{
		$('#SaveAllocBtn').show();
	} else {
		$('#SaveAllocBtn').hide();
	}
};
function checkPayForm()	{
	// console.log("checkPayForm");
	$('#feedback').html("checking entry.")
	$('#btnSavePayment').prop('disabled', true);
	var tranDate = $('#trnDate').val();
	var dateChecked = checkDate(tranDate, false);
//	console.log(' dateChecked ' + dateChecked + ' tranDate ' + tranDate);
	if (!dateChecked) {
		$('#feedback').html("Please enter the date of the transaction.")
		return false;	
	} else {
		if (!checkDateFormat(dateChecked))	{
			$('#feedback').html("Transaction Date is incorrectly formatted.")
			return false;
		} else {
			$('#trnDate').val(dateChecked);
		}
	}
	if ($('#trnMethod').val() == "") {
		$('#feedback').html("Please select the payment method");
		return false;							
	}
	
	let trnAmnt1 = $('#trnAmnt1').val().trim();
	if (isNaN(trnAmnt1) || trnAmnt1 === "") {
		$('#feedback').html("Invalid Net Amount entered.");
		return false;
	}
	trnAmnt1 = Number(trnAmnt1);
	if (trnAmnt1 > 999.99) {
		$('#feedback').html("Transaction Amount entered is too high.");
		return false;	
	}
	trnAmnt1 = Math.round(trnAmnt1);
	
	let trnAmnt2 = $('#trnAmnt2').val().trim();
	if (isNaN(trnAmnt2) || trnAmnt2 === "") {
		trnAmnt2 = 0; // assume empty discount = 0
	} else {
		trnAmnt2 = Number(trnAmnt2);
		if (trnAmnt2 > 999.99) {
			$('#feedback').html("Discount Amount entered is too high.");
			return false;	
		}
		trnAmnt2 = Math.round(trnAmnt2);
	}
	
	if (trnAmnt1 + trnAmnt2 == 0)	{
		$('#feedback').html("Please enter an amount in either the Net Amount or Discount field.")
		return false;			
	}
	$('#btnSavePayment').prop('disabled', false);
	$('#feedback').html("ready to save");
	return true
}
function checkCreditForm()	{
	$('#feedback2').html("checking entry.")
	$('#btnSaveCredit').prop('disabled', true);
	var tranDate = $('#crnDate').val();
	var dateChecked = checkDate(tranDate, false);
	if (!dateChecked) {
		$('#feedback2').html("Please enter the date of the transaction.")
		return false;	
	} else {
		if (!checkDateFormat(dateChecked))	{
			$('#feedback2').html("Transaction Date is incorrectly formatted.")
			return false;
		} else {
			$('#crnDate').val(dateChecked);
		}
	}
	
	let crnAmnt1 = $('#crnAmnt1').val().trim();
	if (isNaN(crnAmnt1) || crnAmnt1 === "") {
		$('#feedback2').html("Invalid Net Amount entered.");
		return false;
	}
	crnAmnt1 = Math.round(crnAmnt1);
	if (crnAmnt1 > 999.99)	{
		$('#feedback2').html("Transaction Amount entered is too high.")
		return false;	
	}
	crnAmnt1 = Math.round(crnAmnt1);
	
	let crnAmnt2 = $('#crnAmnt2').val().trim();
	if (isNaN(crnAmnt2) || crnAmnt2 === "") {
		crnAmnt2 = 0; // assume empty discount = 0
	} else {
		crnAmnt2 = Number(crnAmnt2);
		if (crnAmnt2 > 999.99) {
			$('#feedback2').html("Discount Amount entered is too high.");
			return false;	
		}
		crnAmnt2 = Math.round(crnAmnt2);
	}
	
	if (crnAmnt1 + crnAmnt2 == 0)	{
		$('#feedback2').html("Please enter an amount in either the Net Amount or VAT/Discount field.")
		return false;			
	}
	$('#btnSaveCredit').prop('disabled', false);
	$('#feedback2').html("ready to save");
	return true
}

$(document).ready(function() {
	var isSubmitting = false;

	$('#tabs').tabs(); /* set-up payment tabs */
	$('#menu').dcMegaMenu({rowItems: '3',event: 'hover',fullWidth: false});
	$('.datepicker').datepicker({dateFormat: "yy-mm-dd",changeMonth: true,changeYear: true,showButtonPanel: true, minDate: new Date(2013, 1 - 1, 1)});
	
	$('#addPaymentButton').on('click', function(e) {	<!--- slide payment panel into view --->
	//	$('#payPanel').slideToggle(300); // this doesn't work properly - keeps bouncing open and closed
		$('#payPanel').slideDown(300);
		e.preventDefault();
	});

	$('#viewStatementButton').on('click', function (e) {
	//	console.log(isSubmitting);
		if (isSubmitting) return; // prevent double submission - didn't work
		isSubmitting = true;
		e.preventDefault();
		e.stopImmediatePropagation();	// stop multiple pages appearing - solved the problem
			
		const $form = $('#srchForm');
		const originalTarget = $form.attr('target');
		const originalAction = $form.attr('action');
		const originalEnctype = $form.attr('enctype');
		
		// Temporarily set attributes
		$form.attr({
			action: 'clientStatement2.cfm', // ✅ Replace with actual endpoint
			target: '_blank',
			enctype: 'multipart/form-data'
		});
		
		$form[0].submit();
		// Restore original attributes after a short delay
		setTimeout(function () {
			$form.attr('target', originalTarget);
			$form.attr('action', originalAction);
			$form.attr('enctype', originalEnctype);
			isSubmitting = false;
		}, 100);
	});

	$('#viewAllocButton').on('click', function (e) {
	//	console.log(isSubmitting);
		if (isSubmitting) return; // prevent double submission - didn't work
		isSubmitting = true;
		e.preventDefault();
		e.stopImmediatePropagation();	// stop multiple pages appearing - solved the problem
			
		const $form = $('#srchForm');
		const originalTarget = $form.attr('target');
		const originalAction = $form.attr('action');
		const originalEnctype = $form.attr('enctype');
		
		// Temporarily set attributes
		$form.attr({
			action: 'clientAllocCheck.cfm', // ✅ Replace with actual endpoint
			target: '_blank',
			enctype: 'multipart/form-data'
		});
		
		$form[0].submit();
		// Restore original attributes after a short delay
		setTimeout(function () {
			$form.attr('target', originalTarget);
			$form.attr('action', originalAction);
			$form.attr('enctype', originalEnctype);
			isSubmitting = false;
		}, 100);
	});

 	$('#btnCancel').on('click', function(e) {	<!--- hide payment panel --->
		$('#payPanel').slideUp(300);
		e.preventDefault();
	});
	$('#btnCancel2').on('click', function(e) {	<!--- hide credit panel --->
		$('#payPanel').slideUp(300);
		e.preventDefault();
	});
	$('input').on('focus', function () {
		// Hide any associated error message when this input is focused
		$('#feedback').text('');
	});	
	$('#btnSavePayment').click(function(e) {
		e.preventDefault();
		e.stopImmediatePropagation();
		if (busy)	{
			$('#loadingDiv').html("Busy...")
			return false;
		}
		$(this).prop('disabled', true);
		$('#feedback').html("Saving Payment...")
		if (checkPayForm()) {
			busy = true;
			$.ajax({
				type: 'POST',
				url: 'clientPaymentPost2.cfm',
				data : $("#payForm").serialize(),
				beforeSend:function(){
					$('#loadingDiv').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Saving Payment...").fadeIn();
				},
				success:function(data){
					var clientRef = $('#clientRef').val();
					$('#loadingDiv').html("").fadeOut();
					$('#payForm')[0].reset();
					$('#clientRef').val(clientRef);
					$('#clientRef').focus();
					$('#payResult').html(data);
				},
				error:function(data){
					$('#loadingDiv').html(data).fadeIn();
				},
				complete: function() {
					// Re-enable the button after request is complete
					$('#btnSavePayment').prop('disabled', false);
					$('#loadingDiv').html("not busy")
					$('#feedback').html("")
					// console.log('btnSavePayment function complete');
					busy = false;
			}
			});
		} else {
			// error appears preventing save action
		}
	});
	$('#btnSaveCredit').click(function(e) {
		e.preventDefault();
		e.stopImmediatePropagation();
		if (busy)	{
			$('#loadingDiv').html("Busy...")
			return false;
		}
		$(this).prop('disabled', true);
		$('#feedback2').html("Saving credit...")
		if (checkCreditForm()) {
			busy = true;
			$.ajax({
				type: 'POST',
				url: 'clientPaymentPostCredit2.cfm',
				data : $("#creditForm").serialize(),
				beforeSend:function(){
					$('#loadingDiv').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Saving Credit...").fadeIn();
				},
				success:function(data){
					var clientRef = $('#clientRef').val();
					$('#loadingDiv').html("").fadeOut();
					$('#creditForm')[0].reset();
					$('#clientRef').val(clientRef);
					$('#clientRef').focus();
					$('#payResult').html(data);
				},
				error:function(data){
					$('#loadingDiv').html(data).fadeIn();
				},
				complete: function() {
					// Re-enable the button after request is complete
					$('#btnSaveCredit').prop('disabled', false);
					$('#loadingDiv').html("not busy")
					$('#feedback2').html("")
					// console.log('btnSaveCredit function complete');
					busy = false;
				}
			});
		} else {
			// error appears preventing save action
		}
	});

/*	var shouldSuccess = false;
	$('.datecheck').blur(function(event) {
		var value = $(this).val();
		var isOk = checkDate(value, true);
		if (!isOk) {
			$.messageBox("Date out of range", "error");
			disableSave(true);
			shouldSuccess = true;
		} else {
			if (value.length > 0) {
				$(this).val(isOk);
				if (shouldSuccess) {$.messageBox("Date in range", "success");}
				disableSave(false);
			}
		}
	});
*/
});
