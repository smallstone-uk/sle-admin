var Barcode="";

var delay = (function(){
	var timer = 0;
	return function(callback, ms){
	clearTimeout (timer);
	timer = setTimeout(callback, ms);
	};
})();

function StockScanner(e) {
	var code=Barcode;
	if (e.keyCode == 13) {
		if (code.length >= 8 & code.length <= 14) {
			SendBarcode(Barcode,"code");
			Barcode="";
		} else {
			Barcode="";
		}
	} else {
		if (code != "") {
			var currentString=code;
			var newString=currentString+String.fromCharCode(e.keyCode);
		} else {
			var newString=String.fromCharCode(e.keyCode);
		}
		Barcode=newString;
	}
}
function SendBarcode(code,type) {
	$.ajax({
		type: 'POST',
		url: 'scanPubsCheck.cfm',
		data: {"barcode":code},
		success:function(data){
			if (data.indexOf("error") == 0) {
				$("#orderOverlay").fadeIn();
				$("#orderOverlay-ui").fadeIn();
				$.ajax({
					type: 'POST',
					url: 'scanPubNewLink.cfm',
					data: {"barcode":code},
					beforeSend:function(){
						$("#orderOverlay").fadeIn();
						$("#orderOverlay-ui").fadeIn();
						$('#orderOverlayForm-inner').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
						$('#orderOverlayForm').center();
					},
					success:function(newform){
						$('#loading').fadeOut();
						$('#orderOverlayForm-inner').html(newform);
						$('#orderOverlayForm').center();
					}
				});
			} else {
				$('#loading').html(data).fadeIn();
				$('#ReceivedPubList').val(Number(data));
				$('#ReceivedPubList').trigger('chosen:updated');
				ReceivedPubList(data);
			}
		}
	});
}
function PrintReturnSheet() {
	$.ajax({
		type: 'POST',
		url: 'pubStockPrint.cfm',
		data: $('#printOptionsForm').serialize(),
		success:function(data){
			$('#LoadPrint').html(data).fadeIn(function() {
				$("#orderOverlay").fadeOut();
				$("#orderOverlay-ui").fadeOut();
				PrintArea();
			});
		}
	});
}
function PrintArea() {
	$('#print-area').printArea({extraHead:"<style type='text/css'>@media print {#LoadPrint {position:relative !important;left:0 !important;}}</style>"});
};
function LoadPubs() {
	$.ajax({
		type: 'POST',
		url: 'GetPubs.cfm',
		data : $('#stockForm').serialize(),
		beforeSend:function(){
			$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
		},
		success:function(data){
			$('#pubs').html(data);
			$('#loading').fadeOut();
		},
		error:function(data){
			$('#pubs').html(data);
			$('#loading').fadeOut();
		}
	});
};
function ReceivedPubList(id) {
	$.ajax({
		type: 'POST',
		url: 'GetPubIssue.cfm',
		data : $('#returnPubForm').serialize(),
		beforeSend:function(){
			$('#loading2').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
		},
		success:function(data){
			$('#issue').html(data);
			$('#loading2').fadeOut();
		},
		error:function(data){
			$('#issue').html(data);
			$('#loading2').fadeOut();
		}
	});
};
function CreditedPubList() {
	$.ajax({
		type: 'POST',
		url: 'GetPubIssue.cfm',
		data : $('#creditForm').serialize(),
		beforeSend:function(){
			$('#loading3').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
		},
		success:function(data){
			$('#issue2').html(data);
			$('#loading3').fadeOut();
		},
		error:function(data){
			$('#issue2').html(data);
			$('#loading3').fadeOut();
		}
	});
};
function ClaimPubList() {
	$.ajax({
		type: 'POST',
		url: 'GetPubIssue.cfm',
		data : $('#claimForm').serialize(),
		beforeSend:function(){
			$('#loading4').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
		},
		success:function(data){
			$('#issue4').html(data);
			$('#loading4').fadeOut();
		},
		error:function(data){
			$('#issue4').html(data);
			$('#loading4').fadeOut();
		}
	});
};
function LoadReceived() {
	$.ajax({
		type: 'POST',
		url: 'GetReceivedStock.cfm',
		data : $('#stockForm').serialize(),
		beforeSend:function(){
			$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
		},
		success:function(data){
			$('#receivedlist').html(data);
			$('#loading').fadeOut();
		},
		error:function(data){
			$('#receivedlist').html(data);
			$('#loading').fadeOut();
		}
	});
};
function LoadReturns() {
	$.ajax({
		type: 'POST',
		url: 'GetReturnedStock.cfm',
		data : $('#returnPubForm').serialize(),
		beforeSend:function(){
			$('#loading2').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
		},
		success:function(data){
			$('#returnedlist').html(data);
			$('#loading2').fadeOut();
		},
		error:function(data){
			$('#returnedlist').html(data);
			$('#loading2').fadeOut();
		}
	});
};
function LoadCredits() {
	$.ajax({
		type: 'POST',
		url: 'GetCreditedStock.cfm',
		data : $('#creditForm').serialize(),
		beforeSend:function(){
			$('#loading3').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
		},
		success:function(data){
			$('#creditedlist').html(data);
			$('#loading3').fadeOut();
		},
		error:function(data){
			$('#creditedlist').html(data);
			$('#loading3').fadeOut();
		}
	});
};
function LoadClaims() {
	$.ajax({
		type: 'POST',
		url: 'GetClaimedStock.cfm',
		data : $('#claimForm').serialize(),
		beforeSend:function(){
			$('#loading4').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
		},
		success:function(data){
			$('#claimedlist').html(data);
			$('#loading4').fadeOut();
		},
		error:function(data){
			$('#claimedlist').html(data);
			$('#loading4').fadeOut();
		}
	});
};
function LoadCharges() {
	$.ajax({
		type: 'POST',
		url: 'GetChargedStock.cfm',
		data : $('#chargeForm').serialize(),
		beforeSend:function(){
			$('#loading4').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
		},
		success:function(data){
			$('#chargelist').html(data);
			$('#loading4').fadeOut();
		},
		error:function(data){
			$('#chargelist').html(data);
			$('#loading4').fadeOut();
		}
	});
};
function OpenEdit(id) {
	$.ajax({
		type: 'POST',
		url: 'pubEdit.cfm',
		data : {"pubID":id},
		beforeSend:function(){
			$("#orderOverlay").css("position", "fixed");
			$("#orderOverlay").fadeIn();
			$("#orderOverlay-ui").fadeIn();
			$('#orderOverlayForm-inner').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
			$('#orderOverlayForm').center();
		},
		success:function(data){
			$('#orderOverlayForm-inner').html(data);
			$('#orderOverlayForm').center();
		}
	});
}



