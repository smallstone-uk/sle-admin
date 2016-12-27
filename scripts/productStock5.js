var Barcode = "";

function scanner(e) {
	var currCode=Barcode;
	var keyCode = e.keyCode ? e.keyCode : e.which;
	if (keyCode == 13) { //scanner has finished scanning
		Barcode = "";
		if (currCode.length == 8) {
		//	currCode="00000" + currCode;
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
		url: 'ProductStock5Lookup.cfm',
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

function AddStock(form,result) {
	$.ajax({
		type: 'POST',
		url: 'ProductStock5AddStock.cfm',
		data: $(form).serialize(),
		beforeSend:function(){
			$(result).html("<img src='images/loading_2.gif' class='loadingGif' style='float:none;'>&nbsp;Adding Stock...");
		},
		success:function(data){
			$('#result').html(data);
		//	LoadStockList();
		}
	});
}

function GetCats(groupID,catID,dest) {
	$.ajax({
		type: 'POST',
		url: 'ProductStock5GetCats.cfm',
		data: {"groupID":groupID,"catID":catID},
		success:function(data){
			$(dest).html(data);
		}
	});
}

function xxscanner(e,source,id) {
	var code=Barcode;
	var keyCode = e.keyCode ? e.keyCode : e.which;
	if (keyCode == 13) { //scanner has finished scanning
		Barcode="";
		if (code.length == 8) {
			code="00000"+code;
		} else if (code.length == 12) {
			code="0"+code;
		} else {
			code=code;
		}
		console.log(source + " = " + code);
		return code;
	} else { //building up barcode
		if (code != "") {
			var currentString=code;
			var newString=currentString+String.fromCharCode(keyCode);
		} else {
			var newString=String.fromCharCode(keyCode);
		}
		Barcode=newString;
		console.log("build code = " + Barcode);
		return false;
	}
	return Barcode;
}

function xscanner(e,source,id) {
	var code=Barcode;
	var origCode=Barcode;
	var from=source;
	var keyCode = e.keyCode ? e.keyCode : e.which;
	if (keyCode == 13) { //scanner has finished scanning
		Barcode="";
		if (code.length == 8) {
			code="00000"+code;
		} else if (code.length == 12) {
			code="0"+code;
		} else {
			code=code;
		}
		console.log(code);
		if (code.length == 13) {
		//	LookupBarcode(code,from,id,origCode,1);
		} else {
			code = code.substring(1);
			if (code.length == 13) {
		//		LookupBarcode(code,from,id,origCode,1);
			} else {
				console.log("barcode length incorrect");
			}
		}
	} else { //building up barcode
		if (code != "") {
			var currentString=code;
			var newString=currentString+String.fromCharCode(keyCode);
		} else {
			var newString=String.fromCharCode(keyCode);
		}
		Barcode=newString;
		console.log(Barcode);
	}
	return Barcode;
}

function xLookupBarcode(code,source,id,origCode,tryCount) {
	var from=source;
	$.ajax({
		type: 'POST',
		url: 'ProductStock5Lookup.cfm',
		data: {"barcode":code,"step":1},
		beforeSend:function(){
			$('#result').html("<img src='images/loading_2.gif' class='loadingGif' style='float:none;'>&nbsp;Looking up Product...");
		},
		success:function(data){
			if (data != 0) {
				if (from == "stock") {
					LoadProduct(data,code);
				} else if (from == "addtodeal") {
					AddProductToDeal(data,code,id);
				}
			} else {
				if (tryCount != 2) {
					LookupBarcode(origCode,source,id,origCode,2);
					console.log("origCode"+origCode);
				} else {
					$('#result').html("<h1>Unrecognised barcode</h1><p>This product's barcode is not in our database.</p><img src='images/cross.png' width='128' />");
				}
			}
		}
	});
}

function LoadProduct(id,barcode) {
	$.ajax({
		type: 'POST',
		url: 'ProductStock5Lookup.cfm',
		data: {"id":id,"step":2,"barcode":barcode},
		beforeSend:function(){
			$('#result').html("<img src='images/loading_2.gif' class='loadingGif' style='float:none;'>&nbsp;Checking Order...");
		},
		success:function(data){
			$('#result').html(data);
		//	LoadStockList();
		}
	});
};

function LoadStockList() {
	$.ajax({
		type: 'POST',
		url: 'ProductStock3List.cfm',
		data: "",
		success:function(data){
			$('#resultlist').html(data);
		}
	});
}

function MarkStockItems(form,result) {
	$.ajax({
		type: 'POST',
		url: 'ProductStock3MarkStock.cfm',
		data: $(form).serialize(),
		beforeSend:function(){
			$(result).html("<img src='images/loading_2.gif' class='loadingGif' style='float:none;'>&nbsp;Marking Items...");
		},
		success:function(data){
			$(result).html(data);
			LoadStockList();
		}
	});
}

function SetSubstitute(siID,prodID) {
	$.ajax({
		type: 'POST',
		url: 'ProductStock3SetSubstitute.cfm',
		data: {"siID":siID,"prodID":prodID},
		beforeSend:function(){
			$('#result').html("<img src='images/loading_2.gif' class='loadingGif' style='float:none;'>&nbsp;Assigning...");
		},
		success:function(data){
			$('#result').html(data);
			LoadStockList();
		}
	});
}

function LoadDealsList() {
	$.ajax({
		type: 'POST',
		url: 'ProductStock3DealsList.cfm',
		data: "",
		success:function(data){
			$('#resultlist').html(data);
		}
	});
}

function AddDeal(form) {
	$.ajax({
		type: 'POST',
		url: 'ProductStock3DealsAdd.cfm',
		data: $(form).serialize(),
		success:function(data){
			$('#result').html(data);
		}
	});
}

function LoadAddDeal(deal) {
	$.ajax({
		type: 'POST',
		url: 'ProductStock3DealsAdd.cfm',
		data: {"deal":deal},
		success:function(data){
			$('#result').html(data);
		}
	});
}

function AddProductToDeal(id,barcode,deal) {
	$.ajax({
		type: 'POST',
		url: 'ProductStock3DealsAssign.cfm',
		data: {"id":id,"barcode":barcode,"deal":deal},
		beforeSend:function(){
			$('#result').html("<img src='images/loading_2.gif' class='loadingGif' style='float:none;'>&nbsp;Adding Product...");
		},
		success:function(data){
			$('#result').html(data);
			//LoadAddDeal(deal);
			LoadDealsList();
		}
	});
}

function EditDeal(id) {
	$.ajax({
		type: 'POST',
		url: 'ProductStock3DealsEdit.cfm',
		data: {"dealID":id},
		beforeSend:function(){
			$('#result').html("<img src='images/loading_2.gif' class='loadingGif' style='float:none;'>&nbsp;Loading Deal...");
		},
		success:function(data){
			$('#result').html(data);
			LoadDealsList();
		}
	});
}

function DeleteDeal(form) {
	$.ajax({
		type: 'POST',
		url: 'ProductStock3DealsDelete.cfm',
		data: $(form).serialize(),
		success:function(data){
			LoadDealsList();
		}
	});
}

function PrintDeals(form,result) {
	$.ajax({
		type: 'POST',
		url: 'tickets.cfm',
		data: $(form).serialize(),
		success:function(data){
			$(result).html(data).fadeIn(function() {
				window.print();
			});
		}
	});
}








