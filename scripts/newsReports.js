// news reports functions		2025

function LoadSales ()	{
	$.ajax({
		type: 'POST',
		url: 'ajax/AJAX_newsReports.cfm',
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

function LoadStock ()	{
	$.ajax({
		type: 'POST',
		url: 'ajax/AJAX_newsStock.cfm',
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

