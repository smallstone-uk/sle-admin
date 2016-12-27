
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>

<!DOCTYPE html>
<html>
<head>
	<title>Product Stock Take</title>
	<meta name="viewport" content="width=device-width,initial-scale=1.0">
	<link href="css/main3.css" rel="stylesheet" type="text/css">
	<link href="css/productstock.css" rel="stylesheet" type="text/css">
	<link href="css/labels-small.css" rel="stylesheet" type="text/css">
	<link href="css/chosen.css" rel="stylesheet" type="text/css">
	<link href="css/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" type="text/css">
	<script src="common/scripts/common.js" type="text/javascript"></script>
	<script src="scripts/jquery-1.11.1.min.js" type="text/javascript"></script>
	<script src="scripts/jquery-ui-1.10.3.custom.min.js" type="text/javascript"></script>
	<script src="scripts/jquery.dcmegamenu.1.3.3.js" type="text/javascript"></script>
	<script src="scripts/jquery.hoverIntent.minified.js" type="text/javascript"></script>
	<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
	<script src="scripts/autoCenter.js" type="text/javascript"></script>
	<script src="scripts/popup.js" type="text/javascript"></script>
	<script src="scripts/jquery-barcode.js" type="text/javascript"></script>
	<script src="scripts/productStockTake.js" type="text/javascript"></script>
	<style type="text/css">
		#content {margin-left:20px;}
		.err {color:#FF0000; margin-left:10px}
		.showTable {font-size:18px; margin-bottom:40px; padding:4px;}
		.tableList2 {border-spacing: 0px;border-collapse: collapse;border-color: #CCC;border: 1px solid #CCC;font-size: 14px;}
		.tableList2 th {padding:4px 5px;background:#eee;border-color: #ccc;}
		.tableList2 td {padding: 2px 5px;border-color: #ccc;}
		.request {font-size:24px; color:#FF0000;}
		.ourPrice {font-size:24px; font-weight:bold; margin-top:10px;}
		button {float:none;}
		#result {border:solid 1px #fff;}
		#msg {float:left; padding:10px;}
		#stockform {padding:4px;}
	</style>
	<cfoutput>
		<script type="text/javascript">
			$(document).ready(function() {
				$(document).keypress(function(e){
					var bcode = "";
					if ($('input').is(":focus")) {
						//	data entry in form
						if (e.which == 13) {
							$("##msg").html('');
							var stocklevel = parseInt($("##stockLevel").val());
							var maxlevel = parseInt($("##maxLevel").val());
							if (!$.isNumeric(stocklevel)) {
								//Check if stock level is numeric
								$("##msg").html('please enter a number');
								$("##stockLevel").focus(); //Focus on field
								return false;
							} else if (stocklevel < 0) {
								$("##msg").html('negative values not allowed');
								return false;
//							} else if (stocklevel > maxlevel) {
//								$("##msg").html('too high');
//								return false;
							}
							$.ajax({
								type: "POST",
								url: "#parm.url#ajax/AJAX_stockLevel.cfm",
								data: $('##stockform').serialize(),
								success: function(data) {
									$('##result').html(data);
								}
							});
							e.preventDefault();
						}
					} else {
						bcode = scanner(e);
							console.log("bcode " + bcode);
						if (e.keyCode == 13) {
								// 8712561369534 = Lynx Africa APD
								// 5000435008799 = Golden Virginia
								// 5000393165299 = Cutters choice
								// 5000112604832 = 	Fanta Mango & P/Fruit (no stock records)
								// 5000241001120 = Stork SB
								// 5020379065757 = Lynx Super
								// 5410316945509 = Smirnoff
								// 5000159490269 = Snickers Std
								// 0000096095232 = cadburys fudge
								// 87248548	= Marlboro Kingsize Gold
								// 5028252048569 = Staples (non existent)
							$('##bcode').html(bcode);
						//	if (!bcode) bcode = "5035766641476";
							LookupBarcode("product",bcode);
							e.preventDefault(); // stop form submission
						}
					}
				});
			});
		</script>
	</cfoutput>
</head>

<cfoutput>
<body>
	<div id="wrapper">
		<cfinclude template="sleHeader.cfm">
		<div id="content">
			<div id="loading"></div>
			<h1>Product Stock Take</h1>
			<div id="bcode">Scan product barcode</div>
			<div id="result"></div>
			<div id="msg"></div>
		</div>
	</div>
</body>
</cfoutput>

