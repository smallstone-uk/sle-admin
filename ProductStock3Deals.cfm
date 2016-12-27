<!DOCTYPE html>
<html>
<head>
<title>Deals</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
<link href="css/productstock.css" rel="stylesheet" type="text/css">
<link href="css/labels-small.css" rel="stylesheet" type="text/css">
<link href="css/chosen.css" rel="stylesheet" type="text/css">
<link href="css/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" type="text/css">
<script src="scripts/jquery-1.11.1.min.js"></script>
<script src="scripts/jquery-ui.js"></script>
<script src="scripts/jquery.dcmegamenu.1.3.3.js"></script>
<script src="scripts/jquery.hoverIntent.minified.js"></script>
<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
<script src="scripts/autoCenter.js" type="text/javascript"></script>
<script src="scripts/popup.js" type="text/javascript"></script>
<script src="scripts/jquery.PrintArea.js" type="text/javascript"></script>
<script src="scripts/jquery-barcode.js" type="text/javascript"></script>
<script src="scripts/productStock3.js" type="text/javascript"></script>
<script type="text/javascript">
	$(document).ready(function() { 
		$('#menu').dcMegaMenu({rowItems: '3',event: 'hover',fullWidth: true});
		$('.datepicker').datepicker({
			dateFormat: "yy-mm-dd",
			changeMonth: true,
			changeYear: true,
			showButtonPanel: true,
			minDate: new Date(2013, 1 - 1, 1),
		});
		$('#btnContinue').click(function(e) {
			AddDeal("#newDealForm");
			e.preventDefault();
		});
		$('#btnNew').click(function(e) {
			location.reload();
			e.preventDefault();
		});
		LoadDealsList();
	});
</script>
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
				<a href="##" id="btnNew" class="button">New Deal</a>
				<h1>Deals</h1>
				<div id="resultlist" style="float:left;width:50%;height:600px;"></div>
				<div style="float:left;width:50%;height:600px;overflow:hidden;"> 
					<div id="result" style="padding:20px;margin:0 0 0 10px; text-align:center;">
						<h2>New Deal</h2>
						<form method="post" id="newDealForm">
							<input type="hidden" name="dealID" value="0">
							<table width="300">
								<tr>
									<td width="50%" align="right">Record Title</td>
									<td align="left"><input type="text" name="dealRecordTitle" value=""></td>
								</tr>
								<tr>
									<td align="right">Display Title</td>
									<td align="left"><input type="text" name="dealTitle" value=""></td>
								</tr>
								<tr>
									<td align="right">Starts</td>
									<td align="left"><input type="text" name="dealStarts" value="" class="datepicker"></td>
								</tr>
								<tr>
									<td align="right">Ends</td>
									<td align="left"><input type="text" name="dealEnds" value="" class="datepicker"></td>
								</tr>
								<tr>
									<td align="right">Type</td>
									<td align="left">
										<select name="dealType">
											<option value="discount">Discount</option>
											<option value="quantity">Quantity</option>
											<option value="selection">Selection</option>
										</select><br /><span style="font-size:10px;color:##666;">TODO - 'Type' might not be needed</span>
									</td>
								</tr>
								<tr>
									<td align="right">Amount</td>
									<td align="left">&pound;<input type="number" name="dealAmount" value=""></td>
								</tr>
								<tr>
									<td align="right">Qty</td>
									<td align="left"><input type="number" name="dealQty" value=""></td>
								</tr>
								<tr>
									<td align="right">Status</td>
									<td align="left">
										<select name="dealStatus">
											<option value="active">Active</option>
											<option value="inactive">Inactive</option>
										</select>
									</td>
								</tr>
								<tr>
									<td colspan="2"><input type="button" id="btnContinue" value="Continue"></td>
								</tr>
							</table>
						</form>
					</div>
					<div class="clear"></div>
				</div>
				<div class="clear"></div>
			</div>
		</div>
		<cfinclude template="sleFooter.cfm">
	</div>
	<div id="print-area"><div id="LoadPrint"></div></div>
	<cfif application.site.showdumps>
		<cfdump var="#session#" label="session" expand="no">
		<cfdump var="#application#" label="application" expand="no">
		<cfdump var="#variables#" label="variables" expand="no">
	</cfif>
</body>
</cfoutput>
</html>