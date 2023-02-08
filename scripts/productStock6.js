var Barcode = "";
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
		if (elapsed > 400) { // too long - might have been keystrokes
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
		if (currCode.length == 8) {
			currCode="00000" + currCode;
		}
		Barcode = ""; // clear buffer
		Ticks = 0; // clear timer
		return currCode // return barcode
	}
//	console.log("Ticks " + Ticks + " keycode " + keyCode + " Barcode " + Barcode);
//	return Barcode; // return buffer so far
}


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

function LookupBarcode(source,code,productID,dest) {
	// console.log("LookupBarcode: source=" + source + " code=" + code + " productID=" + productID + " dest=" + dest);
	$.ajax({
		type: 'POST',
		url: 'ProductStock6Lookup.cfm',
		data: {"source":source,"barcode":code,"productID":productID},
		beforeSend:function(){
			$(dest).html("<img src='images/loading_2.gif' class='loadingGif' style='float:none;'>&nbsp;Looking up Product...");
		},
		success:function(data){
			$(dest).html(data);
		}
	});
}

function DeleteBarcode(barID,code,dest) {
	// console.log("DeleteBarcode: " + barID + " code " + code);
	$.ajax({
		type: 'POST',
		url: 'ProductStock6DeleteBarcode.cfm',
		data: {"barcode":code,"barID":barID},
		beforeSend:function(){
			$(dest).html("<img src='images/loading_2.gif' class='loadingGif' style='float:none;'>&nbsp;Deleting barcode...");
		},
		success:function(data){
			$(dest).html(data);
		}
	});
}

function LoadProductByID(source,productID,dest) {
	// console.log("LoadProductByID: source=" + source + " productID=" + productID + " dest=" + dest);	
	$.ajax({
		type: 'POST',
		url: 'ProductStock6Lookup.cfm',
		data: {"source":source,"productID":productID},
		beforeSend:function(){
			$(dest).html("<img src='images/loading_2.gif' class='loadingGif' style='float:none;'>&nbsp;Looking up Product...");
		},
		success: function(data){
			$(dest).html(data);
		}
	});
}

function LookupProductStockID(source,code,dest) {
	// console.log("LookupProductStockID: " + source + " " + code);
	$.ajax({
		type: 'POST',
		url: 'ProductStock6ProdStock.cfm',
		data: {"source":source,"barcode":code},
		beforeSend:function(){
		//	$(dest).html("<img src='images/loading_2.gif' class='loadingGif' style='float:none;'>&nbsp;Looking up Product...");
		},
		success:function(data){
			$(dest).html(data);
		}
	});
}

function AddProductToList(code,prodID) {
	// console.log("AddProductToList: " + prodID);
	$.ajax({
		type: "POST",
		url: "#parm.url#ajax/AJAX_LabelSaveList.cfm",
		data: {"barcode":code, "prodID": prodID},
		beforeSend:function(){
			$('#loading').loading(true);
		},
		success:function(data){
			$('#loading').loading(false);
		},
		error:function(data){
			$('#loading').loading(false);
		}
	});
	e.preventDefault();
}

function AddProduct(form,result) {
	// console.log($(form).serialize());
	$.ajax({
		type: 'POST',
		url: 'ProductStock6Product.cfm',
		data: $(form).serialize(),
		beforeSend:function(){
			$(result).html("<img src='images/loading_2.gif' class='loadingGif' style='float:none;'>&nbsp;Adding Product...");
		},
		success:function(data){
			$(result).html(data);
		}
	});
}

function AmendProduct(form,result) {
	$.ajax({
		type: 'POST',
		url: 'ProductStock6Product.cfm',
		data: $(form).serialize(),
		beforeSend:function(){
			$(result).html("<img src='images/loading_2.gif' class='loadingGif' style='float:none;'>&nbsp;Amending Product...");
		},
		success:function(data){
			// console.log("after amending product " + data);
			$(result).html(data);
		}
	});
}

function LoadStockItems(bcode,productID,allStock,result) {
//	 console.log("LoadStockItems - bcode " + bcode + " productID " + productID + " allStock " + allStock + " result " + result);
	$.ajax({
		type: 'POST',
		url: 'ProductStock6StockItems.cfm',
		data : {"bcode":bcode,"productID":productID,"allStock": allStock },
		beforeSend:function(){
			$(result).html("<img src='images/loading_2.gif' class='loadingGif' style='float:none;'>&nbsp;Loading Stock Items...");
		},
		success:function(data){
			$(result).html(data);
		}
	});
}

function LoadSalesItems(bcode,productID,allStock,result) {
//	 console.log("LoadSalesItems - bcode " + bcode + " productID " + productID + " allStock " + allStock + " result " + result);
	$.ajax({
		type: 'POST',
		url: 'ProductStock6SalesItems.cfm',
		data : {"bcode":bcode,"productID":productID,"allStock": allStock},
		beforeSend:function(){
			$(result).html("<img src='images/loading_2.gif' class='loadingGif' style='float:none;'>&nbsp;Loading Sales Items...");
		},
		success:function(data){
			$(result).html(data);
		}
	});
}

function LoadGroups(result) {
	$.ajax({
		type: 'POST',
		url: 'ProductStock6Groups.cfm',
		beforeSend:function(){
			$(result).html("<img src='images/loading_2.gif' class='loadingGif' style='float:none;'>&nbsp;Loading Groups...");
		},
		success:function(data){
			$(result).html(data);
		}
	});
}

function LoadCategories(group,result) {
	$.ajax({
		type: 'POST',
		url: 'ProductStock6Categories.cfm',
		data : {"group":group},
		beforeSend:function(){
			$(result).html("<img src='images/loading_2.gif' class='loadingGif' style='float:none;'>&nbsp;Loading Categories...");
		},
		success:function(data){
			$(result).html(data);
		}
	});
}

function LoadProducts(category,result) {
	$.ajax({
		type: 'POST',
		url: 'ProductStock6Products.cfm',
		data : {"category":category},
		beforeSend:function(){
			$(result).html("<img src='images/loading_2.gif' class='loadingGif' style='float:none;'>&nbsp;Loading Products...");
		},
		success:function(data){
			$(result).html(data);
		}
	});
}

function DeleteGroup(group,result) {
	$.ajax({
		type: 'POST',
		url: 'ProductStock6GroupDelete.cfm',
		data : {"group":group},
		beforeSend:function(){
			$(result).html("<img src='images/loading_2.gif' class='loadingGif' style='float:none;'>&nbsp;Deleting Group...");
		},
		success:function(data){
			$(result).html(data);
		}
	});
}

function DeleteCategory(category,result) {
	$.ajax({
		type: 'POST',
		url: 'ProductStock6CatDelete.cfm',
		data : {"category":category},
		beforeSend:function(){
			$(result).html("<img src='images/loading_2.gif' class='loadingGif' style='float:none;'>&nbsp;Deleting Category...");
		},
		success:function(data){
			$(result).html(data);
		}
	});
}

function AddStock(form,result) {
	$.ajax({
		type: 'POST',
		url: 'ProductStock6AddStock.cfm',
		data: $(form).serialize(),
		beforeSend:function(){
			$(result).html("<img src='images/loading_2.gif' class='loadingGif' style='float:none;'>&nbsp;Adding Stock...");
		},
		success:function(data){
			$(result).html(data);
			LoadStockItems("",data,result);
		}
	});
}

function SaveStock(form,result) {
	$.ajax({
		type: 'POST',
		url: 'ajax/AJAX_ProductStock6SaveStockItem.cfm',
		data: $(form).serialize(),
		beforeSend:function(){
			$(result).html("<img src='images/loading_2.gif' class='loadingGif' style='float:none;'>&nbsp;Saving Stock...");
		},
		success:function(data){
			$(result).html(data);
			$.closeDialog();
			$.messageBox("Stock Item Saved", "success");
			LoadStockItems("",data,result);
		}
	});
}

function DeleteStockItem(stockitem,productID,result) {
	$.ajax({
		type: 'POST',
		url: 'ProductStock6DeleteStock.cfm',
		data: {"stockitem" : stockitem, "productID" : productID},
		beforeSend:function(){
			$(result).html("<img src='images/loading_2.gif' class='loadingGif' style='float:none;'>&nbsp;Deleting Stock Item...");
		},
		success:function(data){
			$(result).html(data);
			LoadStockItems("",data,result);
		}
	});
}

function GetCats(groupID,catID,dest) {
	$.ajax({
		type: 'POST',
		url: 'ProductStock6GetCats.cfm',
		data: {"groupID":groupID,"catID":catID},
		success:function(data){
			$(dest).html(data);
		}
	});
}

function checkFields () {
	var sendIt = true;
	var supplier = $('#accID').val();
	$('div.err').remove();
	if (supplier == 0) {
		$('#accID').after('<div class="err">Please select a supplier.</div>');
		sendIt = false;
	}
	var qty = parseInt($('#siPackQty').val()) || 0;
	if (qty == 0) {
		$('#siPackQty').after('<div class="err">Please enter the no. of units in each pack.</div>');
		sendIt = false;
	} 
	var qty = parseInt($('#siQtyPacks').val()) || 0;
	if (qty == 0) {
		$('#siQtyPacks').after('<div class="err">Please enter the number of packs received.</div>');
		sendIt = false;
	} 
	var price = parseFloat($('#siWSP').val()).toFixed(2) || 0; 
	if (price == 0 || isNaN(price)) {
		$('#siWSP').after('<div class="err">Please enter the wholesale price of the pack.</div>');
		sendIt = false;
	} 
	var price = parseFloat($('#siRRP').val()).toFixed(2) || 0; 
	if (price == 0 || isNaN(price)) {
		$('#prodPriceMarkedLabel').after('<div class="err">Please enter the retail price of the product.</div>');
		sendIt = false;
	} 
	var price = parseFloat($('#siOurPrice').val()).toFixed(2) || 0; 
	if (price == 0 || isNaN(price)) {
		$('#siOurPrice').after('<div class="err">Please enter our price of the product.</div>');
		sendIt = false;
	} 
	if ($('#soDate').val() == "") {
		$('#soDate').after('<div class="err">Please enter date received.</div>');
		sendIt = false;
	} 
	return sendIt;
}

function checkPrice(target) {
	var vatrate = parseInt($('#prodVATRate').val(),10) / 100; // get VAT multiplier
	var unitPrice = parseFloat($('#siWSP').val() / $('#siPackQty').val()).toFixed(2);	// calc unit trade price
	var retailPrice = $('#siRRP').val();	// get current value
	var ourPrice = $('#siOurPrice').val();	// get current value
	var prodMinPrice = $('#prodMinPrice').val();	// get current value
	// console.log("min price " + prodMinPrice);
	var unitGross = (unitPrice * (1 + vatrate)).toFixed(2); // gross trade price per unit
	var pricemarked = $('#prodPriceMarked').prop('checked');
	if (target == 0) target = 0.43;
	var suggPrice = (unitGross * (1 + target)).toFixed(2);	// calc price at 30% POR
	var lastDigit = suggPrice.toString().slice(-1);
	if (lastDigit != 0) {
		if (lastDigit < 6) {lastDigit = 5}
			else {lastDigit = 9}
		suggPrice = (parseInt(suggPrice*10)*10+lastDigit)/100;
	}
	$('div.err').remove();
	$('#unitPrice').val(unitGross);	// show value
	$('#suggPrice').val(suggPrice);	// show value
	if (pricemarked) {
		ourPrice = retailPrice;
		$('#siOurPrice').val(ourPrice);
		$('#siOurPrice').prop('disabled', true);
	} else {
		$('#siOurPrice').prop('disabled', false);
	}
	if (ourPrice == 0) {
		ourPrice = suggPrice;
		$('#siOurPrice').val(ourPrice);
	}
	if (retailPrice < suggPrice) {
		// ignore it
	}
	if (ourPrice < retailPrice) {
	//	$('#siRRP').after('<div class="err">Our price cannot be less than retail price.</div>');
	} else if (retailPrice > (suggPrice * 1.1)) {
		$('#siRRP').after('<div class="err">Please check retail price is correct.</div>');
	}
	if (!pricemarked) {
		if (ourPrice > (suggPrice * 1.1)) {
			$('#siOurPrice').after('<div class="err">Our price seems too high?</div>');
		} else if (ourPrice < suggPrice) {
			$('#siOurPrice').after('<div class="err">Our price seems too low?</div>');
		}
	}
	var profit = ourPrice - unitGross;
	var por = ((profit / ourPrice) * 100).toFixed(2);
	
	$('#POR').val(por + "%");
	
}
// -------------------------------------- OLDER STUFF  ---------------------------------------
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
		// console.log(source + " = " + code);
		return code;
	} else { //building up barcode
		if (code != "") {
			var currentString=code;
			var newString=currentString+String.fromCharCode(keyCode);
		} else {
			var newString=String.fromCharCode(keyCode);
		}
		Barcode=newString;
		// console.log("build code = " + Barcode);
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
		// console.log(code);
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
		// console.log(Barcode);
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
					// console.log("origCode"+origCode);
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

function LoadStockList(dest) {
	$.ajax({
		type: 'POST',
		url: 'ProductStock6LoadList.cfm',
		data: "",
		success:function(data){
			$(dest).html(data);
		}
	});
}

function AddProductToList(source,bcode,dest) {
	// console.log("barcode " + bcode);
	$.ajax({
		type: 'POST',
		url: 'ProductStock6AddToList.cfm',
		data: {"source":source,"barcode":bcode},
		success:function(data){
			$(dest).html(data);
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

function ExportList(form,result) {
	$.ajax({
		type: 'POST',
		url: 'exportStockList.cfm',
		data: $(form).serialize(),
		success:function(data){
			$(result).html(data).fadeIn(function() {
			//	window.print();
			});
		}
	});
}

function ImportOrder(form,result) {
	$.ajax({
		type: 'POST',
		url: 'stockImportManual.cfm',
		data: $(form).serialize(),
		success:function(data){
			$(result).html(data);
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








