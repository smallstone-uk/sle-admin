
function Calculate() {
	var packqty = Number($('#prodPackQty').val(),10);
	var packprice = Number($('#prodPackPrice').val(),10);
	var rrp = Number($('#prodRRP').val(),10);
	var vat = Number($('#prodVATRate').val(),10);
	var ourmarkup = Number($('#prodOurMarkup').val().replace( /%/g, "" ),10);
	
	var vatrate = 1 + (vat / 100);
	
	if (isNaN(ourmarkup)) {
		ourmarkup = 40
	};
	if (vatrate > 0) {
		var wspgross = packprice * vatrate;
	} else {
		var wspgross = packprice;
	}
	
	if ($('#prodPriceMarked').prop('checked')) {
		var ourprice = rrp;
		var retailvalue = rrp * packqty;
		$('#prodOurMarkup').attr("disabled", true);
		$('#prodOurPrice').html("&pound;" + rrp.toFixed(2));
	} else {
		$('#prodOurMarkup').attr("disabled", false);
		var retailvalue = wspgross * (1 + (ourmarkup / 100));
		var ourprice = retailvalue / packqty;
		$('#prodOurPrice').html("&pound;" + ourprice.toFixed(2));
	}
	var grossprofit = retailvalue - wspgross;
	var RRPPOR = grossprofit / retailvalue * 100;
	var markup = grossprofit / wspgross * 100;
//	$('#retailvalue').val(retailvalue.toFixed(2));
//	$('#grossprofit').val(grossprofit.toFixed(2));
	$('#RRPPOR').html(RRPPOR.toFixed(2)+"%");
	$('#hRRPPOR').val(RRPPOR.toFixed(2));
	$('#prodOurMarkup').val(markup.toFixed(2)+"%");
	$('#hProdOurMarkup').val(markup.toFixed(2));
	$('#hprodOurPrice').val(ourprice.toFixed(2));
//	$('#price').val($('#ourprice').val());
//	$('#ShelfPrice').val($('#ourprice').val());
	return false
};
