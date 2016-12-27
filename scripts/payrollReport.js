;(function($) {
	toPDF = function(content) {
		$.ajax({
			type: "POST",
			url: "ajax/AJAX_createPDF.cfm",
			data: {"content": content},
			beforeSend: function() {},
			success: function(data) {
				$('#PRContent').prepend(data);
				$.messageBox("PDF Created", "success");
			}
		});
	}
})(jQuery);