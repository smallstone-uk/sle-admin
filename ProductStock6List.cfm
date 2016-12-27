<!DOCTYPE html>
<html>
<head>
	<title>Product Stock List 6</title>
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
		.err {color:#FF0000; margin-left:10px}
		.showTable {border-spacing: 0px;border-collapse: collapse;border-color: #CCC; font-size:18px; float:left; margin-right:20px;}
		.showTable td {padding:4px;border-color: #ccc;}
		.tableList3 { border-spacing: 0px;border-collapse: collapse;border-color: #CCC; font-size: 18px;}
		.tableList3 th {padding:4px 5px;background:#eee;border-color: #ccc;}
		.tableList3 td {padding: 2px 5px;border-color: #ccc;}
		.tableList2 {border-spacing: 0px;border-collapse: collapse;border-color: #CCC; font-size: 14px;}
		.tableList2 th {padding:4px 5px;background:#eee;border-color: #ccc;}
		.tableList2 td {padding: 2px 5px;border-color: #ccc;}
		.title {padding:6px; font-size:24px;}
		#bcode {padding:6px; font-size:18px; color:#999999; border:solid 1px #cccccc;}
		.msg {padding:10px; font-size:24px; color:#999999 border:solid 1px #cccccc;}
		#result {padding:10px; font-size:24px; border:solid 1px #cccccc;}
		.panel {float:left; margin:10px 0 0 10px; border: 1px solid #CCC; padding:4px;}
		#entryForm {float:left; margin:10px 0 0 10px; border: 1px solid #CCC; padding:4px;}
		.field, .itemcount, .price, .datepicker, .datepickerTo, .numbersOnly {font-size:18px}
		#AddProductForm {display:none;}
		#AddStockForm {display:none;}
		#AmendProductForm {display:none;}
		.btn {float:left;}
		#groupList {overflow:auto; float:left; height:400px; width:300px; margin-right:10px}
		#catList {overflow:auto; float:left; height:400px; width:300px; margin-right:10px}
		#prodList {overflow:auto; float:left; height:400px; width:300px}
		@page {size:portrait;margin:40px;}
		@media print {
			.tableList {font-size:16px}
			.noprint {display:none};
		}
	</style>
	
	<script src="common/scripts/common.js" type="text/javascript"></script>
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
				if ($('input').is(":focus")) {
					//	data entry in form
				//	console.log("input " + keyCode);
				} else {
					bcode = newscanner(e);
					console.log("code " + bcode);
					if (bcode) {
						$('#bcode').html(bcode);
						AddProductToList("product",bcode,"#result");
						setTimeout(function(){	// wait for db to update
							LoadStockList('#stocklist');
						},500); ;
					}
					e.preventDefault(); // stop form submission
				}
			});
			LoadStockList('#stocklist');
		});
	</script>
</head>

<body>
	<div id="wrapper">
		<cfinclude template="sleHeader.cfm">
		<div id="content">
			<div id="content-inner">
				<div class="title">
					<form method="post">
						Manual Entry: <input name="barcodefld" id="barcodefld" type="text" size="15" maxlength="15" />
						<input type="submit" name="manual" id="manual" class="btn" value="Look up" />
					</form>
					<div style="clear:both"></div>
				</div>
				<div id="bcode"></div>
				<div id="result"></div>
				<div id="stocklist"></div>
			</div>
		</div>
	</div>
</body>
</html>
