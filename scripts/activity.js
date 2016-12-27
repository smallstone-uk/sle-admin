function LoadActivity(days) {
	$.ajax({
		type: 'POST',
		url: 'dashboardActivityList.cfm',
		data: {"days":days},
		success:function(data){
			$('#ActivityResults').html(data);
		}
	});
}
