<!DOCTYPE html>
<html>
<head>
<title>Publication Check</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
<link href="css/chosen.css" rel="stylesheet" type="text/css">
<link href="css/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" type="text/css">
<script src="scripts/jquery-1.9.1.js"></script>
<script src="scripts/jquery-ui-1.10.3.custom.min.js"></script>
<script src="scripts/jquery.dcmegamenu.1.3.3.js"></script>
<script src="scripts/jquery.hoverIntent.minified.js"></script>
<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
<script src="scripts/autoCenter.js" type="text/javascript"></script>
<script src="scripts/popup.js" type="text/javascript"></script>
<script src="scripts/jquery.PrintArea.js" type="text/javascript"></script>
<script src="scripts/pubCheck.js" type="text/javascript"></script>
<script type="text/javascript">
	$(document).ready(function() {
		$(document).keypress(function(e) {
			scanner(e);
		});
		$('.orderOverlayClose').click(function(event) {
			$("#orderOverlay").fadeOut();
			$("#orderOverlay-ui").fadeOut();
			$('#barcode').val("");
			event.preventDefault();
		});
	});
</script>
</head>

<cfoutput>
<body>
	<div id="wrapper">
		<div class="no-print"><cfinclude template="sleHeader.cfm"></div>
		<div id="content">
			<div id="content-inner">
				<div id="orderOverlay-ui"></div>
					<div id="orderOverlay">
					<div id="orderOverlayForm">
						<a href="##" class="orderOverlayClose">X</a>
						<div id="orderOverlayForm-inner"></div>
					</div>
				</div>
				<div class="form-wrap no-print">
					<form method="post" id="scanForm">
						<div class="form-header">
							Publication Barcode Check
							<span></span>
						</div>
						<h3 style=" text-align:center;">Scan Barcode</h3>
						<h2><div id="loading" class="loading"></div></h2>
						<input type="hidden" name="barcode" id="barcode" value="" autocomplete="off">
						<div class="clear"></div>
					</form>
				</div>
				<div class="clear"></div>
				<div id="LoadResult"></div>
				<div class="clear"></div>
			</div>
		</div>
		<div class="no-print"><cfinclude template="sleFooter.cfm"></div>
	</div>
	<cfif application.site.showdumps>
		<cfdump var="#session#" label="session" expand="no">
		<cfdump var="#application#" label="application" expand="no">
		<cfdump var="#variables#" label="variables" expand="no">
	</cfif>
</body>
</cfoutput>
</html>
