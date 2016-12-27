function LoadMessages(days) {
	$.ajax({
		type: 'POST',
		url: 'dashboardMessagesList.cfm',
		data: {"days":days},
		success:function(data){
			$('#msg-outer').html(data);
		}
	});
}

function LoadComments(id) {
	$.ajax({
		type: 'POST',
		url: 'dashboardMessagesComments.cfm',
		data: {"id":id},
		success:function(data){
			$('#comments'+id).html(data).fadeIn();
		}
	});
}

