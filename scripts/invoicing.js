function CreatePDF(t,r,id,ff,oc,fd,td,dd,tt,inv,InvID,ordID,tmode,advance) {
	$.ajax({
		type: 'POST',
		url: 'InvoicingPDF.cfm',
		data: {
			total:t,
			row:r,
			clientID:id,
			fixflag:ff,
			onlycredits:oc,
			fromDate:fd,
			toDate:td,
			invDate:invdate,
			delDate:dd,
			TransType:tt,
			invRef:inv,
			InvID:InvID,
			testmode:tmode,
			advance:advance
		},
		success:function(data){
			$('#orderOverlayForm-inner').html(data);
			$('#orderOverlayForm').center();
			$('#orderOverlay').show();
			$('#orderOverlay-ui').show();
		}
	});
};

var ArrayOfStructs=[];
var index = 0;

function SpoolPDF() {
	if (index == 0) {
		$('#orderOverlay').fadeIn();
		$('#orderOverlay-ui').fadeIn();
		$('#orderOverlayForm-inner').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...");
		$('#orderOverlayForm').center();
	}
	if (index < ArrayOfStructs.length) {
		$.ajax({
			type: 'POST',
			url: 'InvoicingPDF.cfm',
			data: ArrayOfStructs[index],
			success:function(data){
				$('#orderOverlayForm-inner').html(data);
				$('#orderOverlayForm').center();
				$('#orderOverlay').fadeIn();
				$('#orderOverlay-ui').fadeIn();
				++index;
				SpoolPDF();
			}
		});
	}
}
