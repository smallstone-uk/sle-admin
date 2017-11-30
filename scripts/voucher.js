function scanner(e) {
	var code=$('#barcode').val();
	if (e.keyCode == 13) {
		if (code != "") {
			if (code.length < 13) {
				$('#barcode').val("");
				$('#loading').html("Barcode didn't scan properly").fadeIn();
			} else {
				GetVoucher();
				//console.log(code);
			}
		}
	} else {
		var code=$('#barcode').val();
		if (code != "") {
			var currentString=$('#barcode').val();
			var newString=currentString+String.fromCharCode(e.keyCode);
		} else {
			var newString=String.fromCharCode(e.keyCode);
		}
		$('#barcode').val(newString);
		//console.log(newString); //writes barcode to console
	}
}
function GetVoucher() {
	$.ajax({
		type: 'POST',
		url: 'voucherGetVoucher.cfm',
		data: $('#vchForm').serialize(),
		beforeSend:function(){
			$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
		},
		success:function(data){
			if (data.indexOf("error") == 0) {
				$("#orderOverlay").fadeIn();
				$("#orderOverlay-ui").fadeIn();
				$.ajax({
					type: 'POST',
					url: 'voucherNew.cfm',
					data: $('#vchForm').serialize(),
					success:function(newform){
						$('#loading').fadeOut();
						$('#orderOverlayForm-inner').html(newform);
						$('#orderOverlayForm').center();
					}
				});
			} else {
				$('#loading').html(data).fadeIn();
				LoadVouchers();
				$('#barcode').val("");
				$('#qty').val(1);
			}
		}
	});
}
function LoadVouchers() {
	$('#tickRequired').fadeOut();
	$.ajax({
		type: 'POST',
		url: 'voucherLoadList.cfm',
		data: $('#vchForm').serialize(),
		success:function(data){
			$('#LoadResult').html(data);
		}
	});
}
function PrintVouchers() {
	$.ajax({
		type: 'POST',
		url: 'voucherPrint.cfm',
		data: $('#vchForm').serialize(),
		success:function(data){
			$('#LoadPrint').html(data).fadeIn(function() {
				PrintArea();									   	
			});
		}
	});
}
function PrintArea() {
	$('#print-area').printArea({extraHead:"<style type='text/css'>@media print {#LoadPrint {position:relative !important;left:0 !important;}}</style>"});
};





