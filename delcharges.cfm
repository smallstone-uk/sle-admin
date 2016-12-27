<!DOCTYPE html>
<html>
<head>
<title>Delivery Charges</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
<link href="css/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" type="text/css">
<script src="common/scripts/common.js"></script>
<script src="scripts/jquery-1.9.1.js"></script>
<script src="scripts/jquery-ui-1.10.3.custom.min.js"></script>
<script src="scripts/jquery.dcmegamenu.1.3.3.js"></script>
<script src="scripts/jquery.hoverIntent.minified.js"></script>
<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
<script src="scripts/autoCenter.js" type="text/javascript"></script>
<script src="scripts/popup.js" type="text/javascript"></script>
<script src="scripts/jquery.PrintArea.js" type="text/javascript"></script>
<script src="scripts/jquery.tablednd.js"></script>
<script type="text/javascript">
	$(document).ready(function() {
		function LoadList() {
			$.ajax({
				type: 'POST',
				url: 'delChargesList.cfm',
				success:function(data){
					$('#list').html(data);
				}
			});
		}
		LoadList();
	});
</script>
</head>
	
<body>
	<div id="list"></div>
</body>
</html>
