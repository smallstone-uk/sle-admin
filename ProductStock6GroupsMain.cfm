<!DOCTYPE html>
<html>
<head>
	<title>Groups</title>
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
		#groupList {overflow:auto; float:left; height:600px; width:400px; margin-right:10px;}
		#catList {overflow:auto; float:left; height:600px; width:300px; margin-right:10px}
		#prodList {overflow:auto; float:left; height:600px; width:500px}
		#product {min-width:500px;}
		.ourPrice {font-weight:bold; color:#0066CC; font-size:20px}
		#newProduct {float:right}
		.lookup {float:left}
		#textBox {line-height:1em; z-index:99999999}
	</style>
	<script src="common/scripts/common.js" type="text/javascript"></script>
	<script src="scripts/jquery-1.11.1.min.js" type="text/javascript"></script>
	<script src="scripts/jquery-ui-1.10.3.custom.min.js" type="text/javascript"></script>
	<script src="scripts/jquery.dcmegamenu.1.3.3.js" type="text/javascript"></script>
	<script src="scripts/jquery.hoverIntent.minified.js" type="text/javascript"></script>
	<script src="scripts/productStock6.js" type="text/javascript"></script>
	<script src="scripts/main.js"></script>
	<script src="scripts/popup.js" type="text/javascript"></script>
	<script type="text/javascript">
		$(document).ready(function() {
			// Group Functions
			$('#btnNewGroup').click(function(e) {
				$.popupDialog({
					file: "AJAX_loadNewProdGroupForm",
					width: 350
				});
				e.preventDefault();
			});
			$('.editGroup').click(function(e) {
				var id = $(this).attr("data-group");
				$.popupDialog({
					file: "AJAX_ProductStock6AmendGroup",
					data: {"id": id},
					width: 500
				});
				e.preventDefault();
			});
			$('#btnNewCategory').click(function(e) {
				$.popupDialog({
					file: "AJAX_loadNewProdCategoryForm",
					width: 350
				});
				e.preventDefault();
			});
			$('.btnDelete').click(function(e) {
				var group = $(this).attr("data-group");
				var delGroup = confirm("delete group? "+group);
				if (delGroup) {
					DeleteGroup(group,"#result");
					setTimeout(function(){	// wait for db to update
						LoadGroups('#groupsdiv');
					},1000); ;
				}
				e.preventDefault();
			});
			$('.groupItem').click(function(e) {
				var group = $(this).attr("data-group");
				LoadCategories(group,'#catList');
				$('#prodList').html('');
				e.preventDefault();
			});
		});
	</script>
</head>

<cfoutput>
<body>
	<div id="wrapper">
		<cfinclude template="sleHeader.cfm">
		<div id="content">
			<div id="content-inner">
				<cfinclude template="ProductStock6Groups.cfm">
			</div>
		</div>
	</div>
</body>
</cfoutput>
