<!DOCTYPE html>
<html>
<head>
	<title>Product Stock 5</title>
	<meta name="viewport" content="width=device-width,initial-scale=1.0">
	<!---<link href="css/main3.css" rel="stylesheet" type="text/css">--->
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
	<script src="scripts/jquery.PrintArea.js" type="text/javascript"></script>
	<script src="scripts/jquery-barcode.js" type="text/javascript"></script>
	<script src="scripts/productStock5.js" type="text/javascript"></script>
	
	<script type="text/javascript">
		$(document).ready(function() { $("#datepicker")
			$('.datepicker').datepicker({dateFormat: "dd-mm-yy",changeMonth: true,changeYear: true,showButtonPanel: true, minDate: 0});
			$(document).keypress(function(e){
				var bcode = "";
				if ($('input').is(":focus")) {
					//	data entry in form
					bcode = "";
				} else {
					bcode = scanner(e);
					//	console.log("bcode " + bcode);
					if (e.keyCode == 13) {
							// 8712561369534 = Lynx Africa APD  5000435008799
						$('#bcode').html(bcode);
						if (!bcode) bcode = "8712561369534";
						LookupBarcode("product",bcode);
						e.preventDefault(); // stop form submission
					}
				}
			});
		});
	</script>
	<style type="text/css">
		body {font-family:Arial, Helvetica, sans-serif;}
		.err {color:#FF0000; margin-left:10px}
		.showTable {font-size:18px;}
		.tableList3 { border-spacing: 0px;border-collapse: collapse;border-color: #CCC; font-size: 18px;}
		.tableList3 th {padding:4px 5px;background:#eee;border-color: #ccc;}
		.tableList3 td {padding: 2px 5px;border-color: #ccc;}
		
		.tableList2 {border-spacing: 0px;border-collapse: collapse;border-color: #CCC; font-size: 14px;}
		.tableList2 th {padding:4px 5px;background:#eee;border-color: #ccc;}
		.tableList2 td {padding: 2px 5px;border-color: #ccc;}
		.title {margin-left:50px; padding:6px; font-size:18px;}
		#bcode {margin-left:50px; padding:6px; font-size:18px; color:#999999}
		.msg {margin-left:50px; padding:10px; font-size:24px; color:#999999}
		#result {margin-left:50px; padding:10px; font-size:24px;}
		.panel {float:left; margin:10px 0 0 10px; border: 1px solid #CCC; padding:4px;}
		#entryForm {float:left; margin:10px 0 0 10px; border: 1px solid #CCC; padding:4px;}
		h1 {font-size:24px; padding:0px; margin:10px 0 10px 0;}
		.field, .itemcount, .price, .datepicker, .datepickerTo, .numbersOnly {font-size:18px}
	</style>
</head>

<cfoutput>
<body>
	<div id="wrapper">
		<h1 class="title">Scan product...</h1>
		<div id="bcode"></div>
		<div id="result"></div>
	</div>
</body>
</cfoutput>

