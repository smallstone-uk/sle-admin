<!DOCTYPE html>
<html>
<head>
<title>Product Stock 4</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
<link href="css/productstock.css" rel="stylesheet" type="text/css">
<link href="css/labels-small.css" rel="stylesheet" type="text/css">
<link href="css/chosen.css" rel="stylesheet" type="text/css">
<link href="css/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="common/scripts/common.js"></script>
<script src="scripts/jquery-1.11.1.min.js"></script>
<script src="scripts/jquery-ui-1.10.3.custom.min.js"></script>
<script src="scripts/jquery.dcmegamenu.1.3.3.js"></script>
<script src="scripts/jquery.hoverIntent.minified.js"></script>
<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
<script src="scripts/autoCenter.js" type="text/javascript"></script>
<script src="scripts/popup.js" type="text/javascript"></script>
<script src="scripts/jquery.PrintArea.js" type="text/javascript"></script>
<script src="scripts/jquery-barcode.js" type="text/javascript"></script>
<script src="scripts/productStock4.js" type="text/javascript"></script>

<script type="text/javascript">
	$(document).ready(function() { 
		$('#menu').dcMegaMenu({rowItems: '3',event: 'hover',fullWidth: true});
		$('.datepicker').datepicker({dateFormat: "yy-mm-dd",changeMonth: true,changeYear: true,showButtonPanel: true, minDate: 0});
		$(document).keypress(function(e){
			if ($('input').is(":focus")) {
				var barcode=scanner(e,"stock");
				$('#bcode').html(barcode);
			} else {
				var barcode=scanner(e,"stock");
				$('#bcode').html(barcode);
			}
		});
		$('.links').keydown(function(e) {
			var key = e.which;
			console.log(key);
			if (key == 13) {
				var barcode=scanner(e,"stock");
				e.preventDefault();
				return false
			}				
		});
		LoadStockList();
	});
</script>
<style type="text/css">
	.stockItems {border-collapse:collapse;}
	.stockItems td {font-family:Arial, Helvetica, sans-serif; font-size:16px; padding:4px 2px;}
</style>
</head>

<cfoutput>
<body>
	<div id="wrapper">
		<cfinclude template="sleHeader.cfm">
		<div id="content">
			<div id="content-inner">
				<div id="orderOverlay-ui"></div>
				<div id="orderOverlay">
					<div id="orderOverlayForm">
						<a href="##" class="orderOverlayClose">X</a>
						<div id="orderOverlayForm-inner"></div>
					</div>
				</div>
				<a href="ProductStock3Deals.cfm" class="links" target="_blank" tabindex="-1">Deals</a>
				<h1>Book-in Product Stock</h1>
				<div id="resultlist" style="float:left;width:35%;height:600px;"></div>
				<div style="float:left;text-align:center;"><!---overflow:hidden;width:65%;height:600px;--->
					<div id="result"><h1>Scan product barcode</h1></div>
                    <div id="bcode"></div>
				</div>
				<div class="clear"></div>
			</div>
		</div>
		<cfinclude template="sleFooter.cfm">
	</div>
</body>
</cfoutput>
</html>