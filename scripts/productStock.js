var delay = (function(){
	var timer = 0;
	return function(callback, ms){
	clearTimeout (timer);
	timer = setTimeout(callback, ms);
	};
})();

var Barcode="";

function scanner(e) {
	var code=Barcode;
	if (e.keyCode == 13) {
		if (code.length >= 8 & code.length <= 14) {
			//console.log(Barcode);
			GetProduct(Barcode,"code");
			Barcode="";
		} else {
			//console.log(Barcode);
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
		//console.log(Barcode); //writes barcode to console
	}
}

function GetProductBarcode(id) {
	$.ajax({
		type: 'POST',
		url: 'ProductStock2GetBarcode.cfm',
		data : {"prodID":id},
		success:function(code){
			GetProduct(code,"code");
		}
	});
}

function GetProduct(code,type,inputcode) {
	var suppID=$('#supp').val();
	if (type == "code") {
		data={"supp":suppID,"barcode":code};
	} else {
		data={"supp":suppID,"ID":code,"code":inputcode};
	}
	$.ajax({
		type: 'POST',
		url: 'ProductStock2Load.cfm',
		data : data,
		beforeSend:function(){
			$('#scanBarcode').fadeOut();
			$('#result').html("<img src='images/loading_2.gif' class='loadingGif' style='float:none;'>&nbsp;Finding Product...");
		},
		success:function(data){
			$('#result').html(data).fadeIn();
		}
	});
};

function SubmitFormData() {
	$.ajax({
		type: 'POST',
		url: 'ProductStock2Action.cfm',
		data : $('#stockForm').serialize(),
		success:function(data){
			$('#result').html(data).fadeIn();
			$('#scanBarcode').fadeIn();
			setTimeout(function(){
				$('#result').fadeOut();
			}, 5000);
			LoadStockByDate('#stockForm');
		}
	});
}

function SubmitMuliFormData() {
	$.ajax({
		type: 'POST',
		url: 'ProductStock2MultiAction.cfm',
		data : $('#stockForm').serialize(),
		beforeSend:function(){
			$('#findProduct').html("<img src='images/loading_2.gif' class='loadingGif' style='float:none;'>&nbsp;Saving...").fadeIn();
			$('#result').fadeOut();
		},
		success:function(data){
			$('#result').html(data).fadeIn();
			$('#findProduct').html("").fadeOut();
			setTimeout(function(){
				$('#result').fadeOut();
			}, 5000);
			LoadStockByDate('#stockForm');
		}
	});
}

function LoadStockByDate(form) {
	$.ajax({
		type: 'POST',
		url: 'ProductStock2List.cfm',
		data: $(form).serialize(),
		success:function(data){
			$('#resultlist').html(data);
		}
	});
}

function UpdatePOR(units,cost,sell,vat,row) {
	var u=parseFloat(units);
	var c=parseFloat(cost);
	var s=parseFloat(sell);
	var v=parseFloat(vat);
	
	isNaN( u ) ? u = 0 : u = u;
	isNaN( c ) ? c = 0 : c = c;
	isNaN( s ) ? s = 0 : s = s;
	isNaN( v ) ? v = 0 : v = v;
	
	var sv=c + (c / 100) * (v*100);
	var por=(((s * u) - sv) / (s * u) * 100);
	
	var profit=(s * u) - sv;
	
	if (por == "-Infinity") {
		var por = 0;
	}
	if (profit == "-Infinity") {
		var profit=0;
	}
	
	if (row !== undefined) {
        $('#POR'+row).html(por.toFixed(2)+"%");
        $('#Profit'+row).html("&pound;"+profit.toFixed(2));
		if (por < 10) {
			$('#POR'+row).addClass("PORred");
		} else if (por < 20 & por > 10) {
			$('#POR'+row).addClass("PORamber");
		} else {
			$('#POR'+row).addClass("PORgreen");
		}
		if (profit < 0) {
			$('#Profit'+row).addClass("PORred");
		} else {
			$('#Profit'+row).addClass("PORgreen");
		}
    } else {
        $('#POR').html(por.toFixed(2)+"%");
        $('#Profit').html("&pound;"+profit.toFixed(2));
		if (por < 10) {
			$('#POR').addClass("PORred");
		} else if (por < 20 & por > 10) {
			$('#POR').addClass("PORamber");
		} else {
			$('#POR').addClass("PORgreen");
		}
		if (profit < 0) {
			$('#Profit').addClass("PORred");
		} else {
			$('#Profit').addClass("PORgreen");
		}
    }	
}

function SuppSwitch(type,supp) {
	$.ajax({
		type: 'POST',
		url: 'ProductStock2Input.cfm',
		data : {
			"type":type,
			"supp":supp
		},
		beforeSend:function() {
			$('#stockinput').html("<div id='loading'><img src='images/loading_2.gif' class='loadingGif' style='float:none;'>&nbsp;Loading...</div>");
		},
		success:function(data){
			$('#stockinput').html(data);
			LoadStockByDate('#stockForm');
		}
	});
}

function AddMultiRow() {
	var row=$('#rows').val();
	$.ajax({
		type: 'POST',
		url: 'ProductStock2AddRow.cfm',
		data : {"row":row},
		success:function(data){
			$('#NewRows').append(data);
		}
	});
}

function ManageBarcodes(id,row) {
	$.ajax({
		type: 'POST',
		url: 'ProductStock2ManageBarcodes.cfm',
		data: {"id":id,"row":row,"type":"product"},
		beforeSend:function() {
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

function AddNewBarcode(id,type,row,code) {
	$.ajax({
		type: 'POST',
		url: 'ProductStock2AddBarcode.cfm',
		data : {
			"id":id,
			"type":type,
			"barcode":code
		},
		success:function(data){
			ManageBarcodes(id,row);
		}
	});
}

function PrintLabels(form,result) {
	$.ajax({
		type: 'POST',
		url: 'ProductStock6Tickets.cfm',
		data: $(form).serialize(),
		success:function(data){
			$(result).html(data).fadeIn(function() {
				window.print();
				/*delay(function(){
					$('#print-area').printArea({extraHead:"<style type='text/css'>@media print {#LoadPrint {position:relative !important;left:0 !important;}}</style>"});
				}, 3000);*/

			});
		}
	});
}

function PrintArea() {
	$('#print-area').printArea({extraHead:"<style type='text/css'>@media print {#LoadPrint {position:relative !important;left:0 !important;}}</style>"});
}

function DealsManager(form) {
	$.ajax({
		type: 'POST',
		url: 'ProductStock2Deals.cfm',
		data: $(form).serialize(),
		beforeSend:function() {
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

function AddDeal(form) {
	$.ajax({
		type: 'POST',
		url: 'ProductStock2DealsAdd.cfm',
		data: $(form).serialize(),
		success:function(data){
			//LoadDeals();
			$('#NewDeal').html(data);
		}
	});
}

function LoadDeals() {
	$.ajax({
		type: 'POST',
		url: 'ProductStock2DealsLoad.cfm',
		success:function(data){
			$('#dealList').html(data);
		}
	});
}

function AssignDeal(form) {
	$.ajax({
		type: 'POST',
		url: 'ProductStock2DealsAssign.cfm',
		data: $(form).serialize(),
		success:function(data){
		}
	});
}

function AddCategory(type,supp) {
	$.ajax({
		type: 'POST',
		url: 'ProductAddCat.cfm',
		data : {
			"type":type,
			"supp":supp
		},
		beforeSend:function() {
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

