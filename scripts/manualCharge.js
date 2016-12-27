var Barcode="";
var Ticks = 0;

function newscanner(e) {
	var keyCode = e.keyCode ? e.keyCode : e.which; // get key code pressed
	if (Ticks == 0) {	// start a new barcode
		Barcode = "";	// clear buffer
		Ticks = Date.now(); // set the timer
	//	console.log("Ticks was zero");
	} else {
		var ticksNow = Date.now();	// get time right now
		var elapsed = ticksNow - Ticks; // how long since barcode started
		if (elapsed > 200) { // too long - might have been keystrokes
			Barcode = ""; // clear buffer
			Ticks = Date.now(); // reset timer
		}
	//	console.log("Ticks " + Ticks + " ticksNow " + ticksNow +  " elapsed " + elapsed);
	}
	if (keyCode != 13) { // not return key
		Barcode = Barcode + String.fromCharCode(keyCode);	// concat char
	//	console.log("concat barcode " + Barcode);
	} else {
	//	console.log("final code " + Barcode);
		var currCode = Barcode;	// copy final barcode to return
		Barcode = ""; // clear buffer
		Ticks = 0; // clear timer
		return currCode // return barcode
	}
//	console.log("Ticks " + Ticks + " keycode " + keyCode + " Barcode " + Barcode);
//	return Barcode; // return buffer so far
}

function scanner(e) {
	var code=Barcode;
	var keyCode = e.keyCode ? e.keyCode : e.which; // get key code pressed
	if (keyCode == 13) {
		if (code.length >= 8 & code.length <= 14) {
			SendBarcode(Barcode,"code");
			Barcode="";
		} else {
			Barcode="";
		}
	} else {
		if (code != "") {
			var currentString=code;
			var newString=currentString+String.fromCharCode(keyCode);
		} else {
			var newString=String.fromCharCode(keyCode);
		}
		Barcode=newString;
	}
	//console.log(Barcode);
}
function SendBarcode(code,type) {
	$.ajax({
		type: 'POST',
		url: 'scanPubsCheck.cfm',
		data: {"barcode":code},
		success:function(data){
			if (data.indexOf("error") == 0) {
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
				AddCharge(data);
			}
		}
	});
}
function AddCharge(id) {
	//console.log(id);
	$.ajax({
		type: 'POST',
		url: 'manualChargeAdd.cfm',
		data: {
			"date":$('#date').val(),
			"cltID":$('#cltID').val(),
			"orderID":$('#customClients').val(),
			"roundID":$('#roundID').val(),
			"delCharge":$('#delCharge').val(),
			"pubID":id,
			"qty":$('#qty').val()
		},
		beforeSend:function(){
			$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Adding...").fadeIn();
		},
		success:function(data){
			$('#saveResults').html(data);
			$('#saveResults').fadeIn();
			$('#loading').fadeOut();
			$('#pubList').val("");
			$('#qty').val(1);
			$("#pubList").trigger("chosen:updated");
			LoadChargedList();
			setTimeout(function(){$("#saveResults").fadeOut("slow");}, 1000 );
		}
	});
}
function LoadChargedList() {
	$.ajax({
		type: 'POST',
		url: 'manualChargeList.cfm',
		data : $('#chargeForm').serialize(),
		beforeSend:function(){
			$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
		},
		success:function(data){
			$('#result').html(data);
			$('#loading').fadeOut();
		},
		error:function(data){
			$('#result').html(data);
			$('#loading').fadeOut();
		}
	});
};
function LoadList() {
	$.ajax({
		type: 'POST',
		url: 'manualChargeList.cfm',
		data : $('#chargeForm').serialize(),
		beforeSend:function(){
			$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
		},
		success:function(data){
			$('#result').html(data);
			$('#loading').fadeOut();
			Barcode="";
		},
		error:function(data){
			$('#result').html(data);
			$('#loading').fadeOut();
		}
	});
};
function LoadPubs() {
	$.ajax({
		type: 'POST',
		url: 'manualChargeForm.cfm',
		data : $('#chargeForm').serialize(),
		beforeSend:function(){
			$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
		},
		success:function(data){
			$('#pubForm').html(data);
			$('#loading').fadeOut();
			LoadList();
		},
		error:function(data){
			$('#pubForm').html(data);
			$('#loading').fadeOut();
		}
	});
};



