<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Post</title>
	<script type="text/javascript" src="http://kweb.shortlanesendstore.co.uk/common/scripts/jquery-1.7.1.min.js"></script>
	<script type="text/javascript">
		$(document).ready(function() {
			$("#btnSavePayment").click(function(event){
				var $form = $(this);
				var $inputs = $form.find("input, select, button, textarea");
				var serializedData = $form.serialize();
				$.post( 
					"testpost2.cfm",
					serializedData,
					function(data) {
						$('#paymentPanel').html(data);
					}
				);
				event.preventDefault();
			});
		});
	</script>
<script src="jquery-ui-1.10.3.custom.min.js"></script>
</head>


<body>
<form id="foo">
    <label for="bar">A bar</label>
	<div id="paymentPanel"></div>
    <input id="bar" name="bar" type="text" value="" />
    <input type="submit" id="btnSavePayment" value="Send" />
</form>
</body>
</html>