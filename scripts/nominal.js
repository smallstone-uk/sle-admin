function AddRow() {
	var row=$('#Row').val();
	$.ajax({
		type: 'POST',
		url: 'nomMainAddRow.cfm',
		data : {"row":row},
		success:function(data){
			$('#nomList').append(data);
		}
	});
}

function GrossTotal() {
	var net=$('#NetAmount').val();
	var vat=$('#VATAmount').val();
	
	if (net == "") {
		$('#NetAmount').val(0.00);
		net=0.00;
	} else {
		net=parseInt(net,10);
	}
	if (vat == "") {
		$('#VATAmount').val(0.00);
		vat=0.00;
	} else {
		vat=parseInt(vat,10);
	}
	
	var total=net+vat;
	
	$('#GrossTotal').val(total.toFixed(2));
	$('#NetAmount').val(net.toFixed(2));
	$('#VATAmount').val(vat.toFixed(2));
	CheckTotal();
}

function CheckTotal() {
	var gross=Number($('#GrossTotal').val(),10);
	var dr=Number($('#drTotal').html(),10);
	var cr=Number($('#crTotal').html(),10);
	var date=$('#trnDate').val();
	var ref=$('#Ref').val();
	var desc=$('#desc').val();

	if (gross != 0) {
		if (dr != 0 || cr != 0) {
			if (dr == cr & gross == dr) {
				if (date != "" & ref != "" & desc != "") {
					$('#btnSave').prop("disabled",false);
				} else {
					$('#btnSave').prop("disabled",true);
				}
			} else {
				$('#btnSave').prop("disabled",true);
			}
		} else {
			$('#btnSave').prop("disabled",true);
		}
	} else {
		if (dr != 0 || cr != 0) {
			if (dr == cr) {
				if (date != "" & ref != "" & desc != "") {
					$('#btnSave').prop("disabled",false);
				} else {
					$('#btnSave').prop("disabled",true);
				}
			} else {
				$('#btnSave').prop("disabled",true);
			}
		} else {
			$('#btnSave').prop("disabled",true);
		}
	}
}

function GetData(id) {
	$.ajax({
		type: 'POST',
		url: 'nomMainLoadData.cfm',
		data : {"ID":id},
		success:function(data){
			$('#nomList').html(data);
		}
	});
}

function TotalDR() {
	var line=0;
	$('.drRowItem').each(function() {
		var id=$(this).attr("alt");
		if ($(this).val() == "") {
			value=0;
			$('#crValue'+id).prop("disabled",false);
		} else {
			value=Number($(this).val(),10);
			$(this).val(value.toFixed(2));
			$('#crValue'+id).prop("disabled",true);
		}
		line=line+Number(value,10);
	});
	$('#drTotal').html(line.toFixed(2));
	if (value != 0) {
		AddRow();
	}
	CheckTotal();
}

function TotalCR() {
	var line=0;
	$('.crRowItem').each(function() {
		var id=$(this).attr("alt");
		if ($(this).val() == "") {
			value=0;
			$('#drValue'+id).prop("disabled",false);
		} else {
			value=Number($(this).val(),10);
			$(this).val(value.toFixed(2));
			$('#drValue'+id).prop("disabled",true);
		}
		line=line+Number(value,10);
	});
	$('#crTotal').html(line.toFixed(2));
	if (value != 0) {
		AddRow();
	}
	CheckTotal();
}

function Reset() {
	$('#nomList').html("");
	$('#nomForm').trigger("reset");
	$('#btnSave').val("Save");
	$('#Mode').val(1);
	$('#Row').val(0);
	$('#drTotal').html("");
	$('#crTotal').html("");
	$('#result').html("");
	CheckTotal();
	AddRow();
}

function WorkOutMonthInt(d) {
	var d=new Date(d);
	var date=d.getMonth();
	date=date+1;
	if (date == 1) {
		diff=12;
	} else if (date == 2) {
		diff=1;
	} else if (date == 3) {
		diff=2;
	} else if (date == 4) {
		diff=3;
	} else if (date == 5) {
		diff=4;
	} else if (date == 6) {
		diff=5;
	} else if (date == 7) {
		diff=6;
	} else if (date == 8) {
		diff=7;
	} else if (date == 9) {
		diff=8;
	} else if (date == 10) {
		diff=9;
	} else if (date == 11) {
		diff=10;
	} else if (date == 12) {
		diff=11;
	}
	$('#nomDateIntResult').html("Nom Month: "+diff);
}













