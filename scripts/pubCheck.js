var Barcode="";

function scanner(e) {
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
				$('#barcode').val("");
				//$('#qty').val(1);
			}
		}
	});
}





