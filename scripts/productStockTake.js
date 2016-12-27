// JavaScript Document

var Barcode = "";

function scanner(e) {
	var currCode=Barcode;
	var keyCode = e.keyCode ? e.keyCode : e.which;
	if (keyCode == 13) { //scanner has finished scanning
		Barcode = "";
		if (currCode.length == 8) {
			currCode="00000" + currCode;
		} else if (currCode.length == 12) {
			currCode = "0" + currCode;
		}
		return currCode;
	} else { //building up barcode
		Barcode = Barcode + String.fromCharCode(keyCode);
	}
	return Barcode;
}

function LookupBarcode(source,code) {
	// console.log("LookupBarcode: " + source + " " + code);
	$.ajax({
		type: 'POST',
		url: 'ProductStockTakeLookup.cfm',
		data: {"source":source,"barcode":code},
		beforeSend:function(){
			$('#result').html("<img src='images/loading_2.gif' class='loadingGif' style='float:none;'>&nbsp;Looking up Product...");
		},
		success:function(data){
			$('#result').html(data);
		}
	});
}

function AddProduct(form,result) {
	$.ajax({
		type: 'POST',
		url: 'ProductStock5Add.cfm',
		data: $(form).serialize(),
		beforeSend:function(){
			$(result).html("<img src='images/loading_2.gif' class='loadingGif' style='float:none;'>&nbsp;Adding Product...");
		},
		success:function(data){
			$('#result').html(data);
		//	LoadStockList();
		}
	});
}

