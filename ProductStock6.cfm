<!DOCTYPE html>
<html>
<head>
	<title>Product Stock 6</title>
	<meta name="viewport" content="width=device-width,initial-scale=1.0">
	<link href="css/main3.css" rel="stylesheet" type="text/css">
	<link href="css/main4.css" rel="stylesheet" type="text/css">
	<link href="css/productstock.css" rel="stylesheet" type="text/css">
	<link href="css/labels-small.css" rel="stylesheet" type="text/css">
	<link href="css/chosen.css" rel="stylesheet" type="text/css">
	<link href="css/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" type="text/css">
	<style type="text/css">
		body {font-family:Arial, Helvetica, sans-serif;}
		h1 {font-size:24px; padding:0px; margin:10px 0 10px 0;}
		.title2 {font-size:18px; padding:0px; margin:10px 0 10px 0;}
		.err {color:#FF0000; margin-left:10px; font-size:14px;}
		.showTable {border-spacing: 0px;border-collapse: collapse;border-color: #CCC; font-size:18px; float:left; margin:6px 6px 10px 0}
		.showTable td {padding:4px;border-color: #ccc;}
		.tableList3 { border-spacing: 0px;border-collapse: collapse;border-color: #CCC; font-size: 18px;}
		.tableList3 th {padding:4px 5px;background:#eee;border-color: #ccc;}
		.tableList3 td {padding: 2px 5px;border-color: #ccc;}
		.tableList2 {border-spacing: 0px;border-collapse: collapse;border-color: #CCC; font-size: 14px;}
		.tableList2 th {padding:4px 5px;background:#eee;border-color: #ccc;}
		.tableList2 td {padding: 2px 5px;border-color: #ccc;}
		.title {padding:6px; font-size:24px;}
		#bcode {padding:6px; font-size:18px; color:#999999; border:solid 1px #cccccc; width:200px; float:left}
		#productID {padding:6px; font-size:18px; color:#999999; border:solid 1px #cccccc; width:200px; float:left}
		#msgs {padding:2px; font-size:18px; color:#ff802e; border:solid 1px #cccccc;}
		.msg {padding:10px; font-size:24px; color:#999999 border:solid 1px #cccccc;}
		#result {padding:10px; font-size:24px; border:solid 1px #cccccc;}
		.panel {float:left; margin:10px 0 0 10px; border: 1px solid #CCC; padding:4px;}
		#entryForm {float:left; margin:10px 0 0 10px; border: 1px solid #CCC; padding:4px;}
		.field, .itemcount, .price, .datepicker, .datepickerTo, .numbersOnly {font-size:18px}
		#AddProductForm {display:none;}
		#AddStockForm {display:none;}
		#AmendProductForm {display:none;}
		#groupList {overflow:auto; float:left; height:400px; width:350px; margin-right:10px}
		#catList {overflow:auto; float:left; height:400px; width:300px; margin-right:10px}
		#prodList {overflow:auto; float:left; height:400px; width:500px}
		#product {min-width:500px;}
		.ourPrice {font-weight:bold; color:#0066CC; font-size:20px}
		#newProduct {float:right}
		.lookup {float:left}
		#textBox {line-height:1em; z-index:99999999}
		.negativeNum {color:#FF0000}
	</style>
	
	<!---<script src="common/scripts/common.js" type="text/javascript"></script>--->
	<script src="scripts/jquery-1.11.1.min.js" type="text/javascript"></script>
	<script src="scripts/jquery-ui-1.10.3.custom.min.js" type="text/javascript"></script>
	<script src="scripts/jquery.dcmegamenu.1.3.3.js" type="text/javascript"></script>
	<script src="scripts/jquery.hoverIntent.minified.js" type="text/javascript"></script>
	<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
	<script src="scripts/autoCenter.js" type="text/javascript"></script>
	<script src="scripts/popup.js" type="text/javascript"></script>
	<script src="scripts/jquery.PrintArea.js" type="text/javascript"></script>
	<script src="scripts/jquery-barcode.js" type="text/javascript"></script>
	<script src="scripts/productStock6.js" type="text/javascript"></script>
	<script src="scripts/main.js"></script>
	<script src="scripts/popup.js" type="text/javascript"></script>
	
	<script type="text/javascript">
		$(document).ready(function() {
			
			$(document).keypress(function(e){
				var bcode = "";
				var keyCode = e.keyCode ? e.keyCode : e.which; // get key code pressed
				if ($('input').is(":focus")  || $('select').is(":focus")) {
					//	data entry in form
				//	console.log("input " + keyCode);
				} else {
					bcode = newscanner(e);
				//	console.log("code " + bcode);
					if (bcode) {
						$('#bcode').val(bcode);
						$('#result').html("");
						LookupBarcode("product",bcode,0,"#productdiv");
						$("#tabs").tabs({
						  active: 0
						});
					}
					e.preventDefault(); // stop form submission
				}
				$('#manual').click(function(e) {
					bcode = $('#barcodefld').val()
					if (bcode) {
						$('#bcode').val(bcode);
						$('#result').html("");
						$('#barcodefld').val("");
						LookupBarcode("product",bcode,0,"#productdiv");
						$("#tabs").tabs({
						  active: 0
						});
					}
					e.preventDefault(); // stop form submission
				});
			});
			
			$('.datepicker').datepicker({dateFormat: "dd-mm-yy",changeMonth: true,changeYear: true,showButtonPanel: true, minDate: new Date(2013, 1 - 1, 1)});
			$(function() {
				$("#tabs").tabs();
			});
			$('#productTab').click(function() {
				var	bcode = $('#bcode').val()
				var	productID = $('#productID').val()
				LookupBarcode("product",bcode,productID,"#productdiv");
				$('#productTab').blur();
			});
			$('#stockTab').click(function() {
				var	bcode = $('#bcode').val()
				var	productID = $('#productID').val()
				var	allStock = $('#allStock').is(':checked')
				LoadStockItems(bcode,productID,allStock,'#stockdiv');
				$('#stockTab').blur();
			});
			$('#salesTab').click(function() {
				var	bcode = $('#bcode').val()
				var	productID = $('#productID').val()
				var	allStock = $('#allStock').is(':checked')
				LoadSales(bcode,productID,allStock,'#salesdiv');
				$('#salesTab').blur();
			});
			$('#itemsTab').click(function() {
				var	bcode = $('#bcode').val()
				var	productID = $('#productID').val()
				var	allStock = $('#allStock').is(':checked')
				LoadSalesItems(bcode,productID,allStock,'#itemsdiv');
				$('#itemsTab').blur();
			});
			$('#analysisTab').click(function() {
				var	bcode = $('#bcode').val()
				var	productID = $('#productID').val()
				var	allStock = $('#allStock').is(':checked')
				LoadAnalysis(bcode,productID,allStock,'#analysisdiv');
				$('#analysisTab').blur();
			});
			$('#groupsBtn').click(function() {
				window.open( 'ProductStock6GroupsMain.cfm' );
			});
			$('.price').blur(function(e) {
				var retailPrice = $('#prodRRP').val();
				if ($('#prodPriceMarked').prop('checked'))
					$('#prodOurPrice').val(retailPrice);
			});
			$('#prodPriceMarked').click(function(e) {
				var retailPrice = $('#siRRP').val();
				if ($('#prodPriceMarked').prop('checked'))
					$('#siOurPrice').val(retailPrice);
			});
			$('#newProduct').click(function(e) {
				var	bcode = "";
				LookupBarcode("product",bcode,0,"#productdiv");
				$("#tabs").tabs({
				  active: 0
				});
			});
		});
		<cfif StructKeyExists(url,"product")>
			<cfoutput>
				LoadProductByID("product",#url.product#,"##productdiv");
			</cfoutput>
		</cfif>
	</script>
</head>

<cfoutput>
<body>
	<div id="wrapper">
		<cfinclude template="sleHeader.cfm">
		<div id="content">
			<!---<div id="loadingDiv">loadingDiv</div>
			<div id="feedback">feedback</div>--->
			<div id="content-inner">
				<form method="post" id="prodSearch">
					<table class="tableList" border="1">
						<tr>
							<td><input type="hidden" name="bcode" id="bcode" size="10" /></td>
							<td><input type="hidden" name="productID" id="productID" size="10" /></td>
							<td colspan="3"></td>
						</tr>
						<tr>
							<td><span class="lookup">Enter or scan barcode: &nbsp;</span></td>
							<td>
								<input type="text" name="barcodefld" id="barcodefld" class="lookup" size="15" maxlength="20" />
							</td>
							<td>
								<input type="button" name="manual" id="manual" class="lookup" style="float:left" value="Look-up" />						
							</td>
							<td>
								<button type="button" id="newProduct">Add New Product</button> &nbsp;
							</td>
							<td>
								<button type="button" id="groupsBtn">Groups & Categories</button>											
							</td>
						</tr>
						<tr>
							<td align="right">Search Date From</td>
							<td>
								<input type="text" name="srchDateFrom" id="srchDateFrom" class="datepicker" size="10" autoComplete="off"  />
							</td>
							<td align="right">Search Date To</td>
							<td>
								<input type="text" name="srchDateTo" id="srchDateTo" class="datepicker" size="10" autocomplete="off"  />
							</td>
							<td><input type="checkbox" name="allStock" id="allStock" value="1" />Show all stock records</td>
						</tr>
					</table>
				</form>

<!---					<div class="title">
						<div style="clear:both"></div>
					</div>
					<div id="content-header">
						<div id="bcode"></div>
						<div id="productID"></div>
						
						<div style="clear:both"></div>
					</div>
--->	
				<div id="tabs">
					<ul>
						<li><a href="##productdiv" id="productTab">Product</a></li>
						<li><a href="##stockdiv" id="stockTab">Purchases</a></li>
						<li><a href="##salesdiv" id="salesTab">Monthly Sales</a></li>
						<li><a href="##itemsdiv" id="itemsTab">Sales Items</a></li>
						<li><a href="##analysisdiv" id="analysisTab">Analysis</a></li>
					</ul>
					<div id="productdiv"><div class="title">Scan product...</div></div>
					<div id="stockdiv"></div>
					<div id="groupsdiv"></div>
					<div id="salesdiv"></div>
					<div id="itemsdiv"></div>
					<div id="analysisdiv"></div>
					<div style="clear:both"></div>
					<div id="result"></div>
				</div>
			</div>
		</div>
	</div>
</body>
</cfoutput>
