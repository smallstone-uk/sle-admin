<!DOCTYPE html>
<html>
<head>
<title>Door Codes</title>
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
		function LoadCodes() {
			$.ajax({
				type: 'POST',
				url: 'doorcodesList.cfm',
				success:function(data) {
					$('#print-area').html(data);
				}
			});
		}
		function PrintArea() {
			$('#print-area').printArea();
		};
		$('#printBanking').click(function(e) {
			PrintArea();
			e.preventDefault();
		});
		LoadCodes();
	});
</script>
</head>
<cfsetting requesttimeout="300">

<cfoutput>
<body>
	<div id="controls" style="background: ##EEE;padding: 10px;border-bottom: 1px solid ##CCC;">
		<a href="##" id="printBanking" class="button" style="float:left;font-size:13px;">Print</a>
		<div style="float:left;" id="loading" class="loading"></div>
		<div class="clear"></div>
	</div>
	<div id="print-area" style=" font-family:Arial, Helvetica, sans-serif;font-size:11px;padding:10px;width:860px;">
	</div>
	<div style="clear:both;"></div>
</body>
</cfoutput>