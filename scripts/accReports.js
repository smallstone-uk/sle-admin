// accounting reports functions		2025

function xDispatch (e,form)	{
	console.log(form);
	var srchReport = form.srchReport;
	console.log(srchReport);
	e.preventDefault();
	e.stopPropagation();
}

function LoadGroups ()	{
	$.ajax({
		type: 'POST',
		url: 'ajax/AJAX_accReports.cfm',
		data: $('#srchForm').serialize(),
		beforeSend:function(){
			$("#resultDiv").empty(); // clear out old stuff
			$("#resultDiv").hide(); 
			$('#loadingDiv').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
		},
		success:function(data){
			$('#loadingDiv').html('&nbsp;');
			$('#resultDiv').html(data).show();
		},
		error:function(data){
			$('#resultDiv').html(data);
			$('#loadingDiv').loading(false);
		}
	});				
}

function EditGroup(ref,mode,group,title,srchDateFrom,srchDateTo,result) {
	$.ajax({
		type: 'POST',
		url: 'ajax/AJAX_EditGroup.cfm',
		data: {"ref":ref,"mode":mode,"group":group,"title":title,"srchDateFrom":srchDateFrom,"srchDateTo":srchDateTo},
		beforeSend:function(){
			$(result).html("<img src='images/loading_2.gif' class='loadingGif' style='float:none;'>&nbsp;Loading...");
		},
		success:function(data){
			$(result).html(data);
		}
	});
}

function ViewTrans(ref,mode,group,title,srchDateFrom,srchDateTo,result) {
	$.ajax({
		type: 'POST',
		url: 'ajax/AJAX_ViewTrans.cfm',
		data: {"ref":ref,"mode":mode,"group":group,"title":title,"srchDateFrom":srchDateFrom,"srchDateTo":srchDateTo},
		beforeSend:function(){
			$(result).html("<img src='images/loading_2.gif' class='loadingGif' style='float:none;'>&nbsp;Loading...");
		},
		success:function(data){
			$(result).html(data);
		}
	});
}
			
function closeModal() {
	$("#overlay, #modal").fadeOut(150, function () {
		$("#modal-content").empty(); // clear out old stuff
		$("body").removeClass("modal-open");
	});
}

$(document).on("click", ".pm-flag", function() {
	var $el = $(this);
	//console.log($(this));
	var id = $el.data("id");
	var tran = $el.data("tran");
	var currentVal = $el.data("value");
	var toggle = $el.data("toggle");
	//console.log(currentVal);
	var newVal = toggle == 1 ? 0 : 1;
	//console.log("newVal " + newVal);
	$.ajax({
		url: "ajax/AJAX_accInvertValue.cfm",
		method: "POST",
		data: { recordID: id, value: currentVal},
		success: function(response) {
			// Update DOM only if CF update succeeded
			$el.data("toggle", newVal);
			$el.data("value", -currentVal);
			//console.log($('#'+id));
			var newValue = Number(response).toFixed(2);
			$('#'+id).html(newValue);
			if (newVal == 0) {
				$el.find("i.icon-img").removeClass("cross").addClass("tick");
				$el.find("i.icon-text").html(newValue);
			} else {
				$el.find("i.icon-img").removeClass("tick").addClass("cross");
				$el.find("i.icon-text").html(newValue);
			}
			//console.log('response ' +response);
			total(tran);
		}
	});
});

function total(tranClass) {
	var tranTotal = 0;
	$('.tran'+tranClass).each(function( index ) {
		var value = Number($(this).html());
		value = Math.round(value * 100) / 100
		//console.log('item value = '+value);
		tranTotal = tranTotal + value;
	})
	tranTotal = Math.round(tranTotal * 100) / 100
	if (tranTotal == 0) {
		$('#bal'+tranClass).removeClass("balanceError");
	} else {
		$('#bal'+tranClass).addClass("balanceError");
	}
	//console.log('#bal'+tranClass + ' balance = ' + tranTotal);
	$('#bal'+tranClass).html(tranTotal.toFixed(2));
};
