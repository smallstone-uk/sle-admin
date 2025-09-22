// accounting reports functions		2025

function EditGroup(ref,mode,group,srchDateFrom,srchDateTo,result) {
	$.ajax({
		type: 'POST',
		url: 'ajax/AJAX_EditGroup.cfm',
		data: {"ref":ref,"mode":mode,"group":group,"srchDateFrom":srchDateFrom,"srchDateTo":srchDateTo},
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
