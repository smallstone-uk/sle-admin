<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>Import Data</title>
	<link rel="stylesheet" type="text/css" href="css/main.css"/>
	<style>
		.more {color:#553FFF; font-size:16px; font-weight:bold; background-color:#D47FAA !Important}
		.insert {color:#0F0;}
		.update {color:#0000FF;}
		.missing {color:#F00;}
		.dataTable {
			font-family:Arial, Helvetica, sans-serif;
			font-size:12px;
			border-collapse:collapse;
		}
		.dataTable th, .dataTable td {
			padding:2px 4px; 
			border: solid 1px #ccc;
		}
		/* */
		.stockPanel {background-color:#FCF;}
		.productPanel {background-color:#CCFFFF;}
		.pricemarked {
			color: #FF00ff;
			font-size: 16px;
			font-weight: bold !Important;
		}
		
		.pricemarkdiff {
			color: #FF00ff;
			background-color: #6633FF;
			font-size: 16px;
			font-weight: bold !Important;
		}
		
		.pm-flag {
			display: inline-flex;
			align-items: center;
			justify-content: center;
			width: 30px;
			height: 30px;
			cursor: pointer;
		}
		
		.pm-flag .icon-img {
			display: block;
			width: 30px;
			height: 30px;
			background-repeat: no-repeat;
			background-position: center center;
			background-size: contain;
		}
		
		.pm-flag .tick {
			background-image: url("/images/icons/tick-round.png");
		}
		
		.pm-flag .cross {
			background-image: url("/images/icons/cross-round.png");
		}
		.pm-flag .warning {
			background-image: url("/images/icons/warning.png");
		}
	</style>
	<script src="scripts/jquery-1.11.1.min.js"></script>
	<script src="scripts/jquery-ui-1.10.3.custom.min.js"></script>
	<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
	<script type="text/javascript">
		$(document).ready(function() {
			$(document).on("click", ".pm-flag", function() {
				var $el = $(this);
				var id = $el.data("id");
				var currentVal = $el.data("pm");
				var newVal = currentVal == 1 ? 0 : 1;
			
				$.ajax({
					url: "ajax/AJAX_productSetValue.cfm",
					method: "POST",
					data: { productID: id, pm: newVal },
					success: function(response) {
						// Update DOM only if CF update succeeded
						$el.data("pm", newVal);
						if (newVal == 1) {
							$el.find("i.icon-img").removeClass("warning").addClass("tick");
							$el.find("i.icon-img").removeClass("cross").addClass("tick");
							$el.find("i.icon-text").html(response);
						} else {
							$el.find("i.icon-img").removeClass("tick").addClass("cross");
							$el.find("i.icon-text").html(response);
						}
					}
				});
			});
			$(document).on("click change", ".QtyPacks", function() {
				var $el = $(this);
				var id = $el.data("id");
				var currentVal = $el.val();
				console.log("stock ID " + id, " QtyPacks " + currentVal);
				$.ajax({
					url: "ajax/AJAX_setCaseQty.cfm",
					method: "POST",
					data: { stockItemID: id, QtyPacks: currentVal },
					success: function(response) {
						// Update DOM only if CF update succeeded
					}
				});
			});
		});
	</script>
</head>

<cfobject component="code/import4" name="import">
<cfparam name="supplierID" default="21">	<!--- Booker --->
<cfparam name="fileSrc" default="">
<cfparam name="srchMode" default="1">
<cfif len(fileSrc) IS 0>
	<p>Please select a file <a href="bookerProcess.cfm">here</a></p>
	<cfexit>
</cfif>
<cfset parm = {}>
<cfset parm.markup = 143>
<cfset parm.fieldCount = 11>
<cfset parm.fileDir = "#application.site.dir_data#stock\">
<cfset parm.sourcefile = fileSrc>
<cfset parm.supplierID = supplierID>
<cfset parm.stockOrderID = 0>

<cfif FindNoCase("prom",fileSrc,1)>
	<cfset parm.orderDate = ListGetAt(fileSrc,2,"-")>
	<cfif IsDate(parm.orderDate)>
		<cfset parm.orderRef = DateFormat(parm.orderDate,"yyyymmdd")>				
	<cfelse>
		<cfset parm.orderRef = ListFirst(fileSrc,"-")>
	</cfif>
	<cfset parm.validTo = ListFirst(ListGetAt(fileSrc,3,"-"),".")>
<cfelse>
	<cfset parm.orderDate = ListGetAt(fileSrc,2,"-")>
	<cfset parm.orderRef = ListFirst(ListGetAt(fileSrc,3,"-"),".")>
	<cfset parm.validTo = "">
</cfif>

<body>
	<p>v4.0</p>
	<cfoutput>
		<cfset orderStatus = import.StockOrderStatus(parm)>
		<form name="processForm" method="post" enctype="multipart/form-data">
			<input type="hidden" name="sourcefile" value="#parm.sourcefile#" />
			<input type="hidden" name="fileDir" value="#parm.fileDir#" />
			<input type="hidden" name="supplierID" value="#parm.supplierID#" />
			<input type="hidden" name="orderRef" value="#parm.orderRef#" />
			<input type="hidden" name="orderDate" value="#parm.orderDate#" />
			<table class="tableStyle" border="1" width="500">
				<tr>
					<th colspan="2" align="left">Import Settings</th>
				</tr>
				<tr>
					<th>Import File</th>
					<td>#parm.sourcefile# <a href="bookerProcess.cfm">Select File...</a></td>
				</tr>
				<tr>
					<td>Processing Mode</td>
					<td>
						<input type="radio" name="srchMode" value="1" checked="checked" /> View Only
						<input type="radio" name="srchMode" value="2" /> Import Data
					</td>
				</tr>
				<tr>
					<th>Barcode Data</th>
					<td><input type="checkbox" name="srchBarcodes" value="1" />Show barcode scanner data</td>
				</tr>
				<tr>
					<th colspan="2" align="left"><input type="submit" name="srchGo" value="Process File..." id="srchGo" /></th>
				</tr>
				<tr>
					<th></th>
					<td>#orderStatus.msg#</td>
				</tr>
				<cfif StructKeyExists(orderStatus,"soID")>
					<tr>
						<th>Order ID</th>
						<td>#orderStatus.soID#</td>
					</tr>
					<tr>
						<th>Order Date</th>
						<td>#orderStatus.soDate#</td>
					</tr>
					<tr>
						<th>Order Reference</th>
						<td>#orderStatus.soRef#</td>
					</tr>
					<tr>
						<th>Scanned</th>
						<td>#orderStatus.soScanned#</td>
					</tr>
					<tr>
						<th>Status</th>
						<td>#orderStatus.soStatus#</td>
					</tr>
					<tr>
						<th>Items Found</th>
						<td>#orderStatus.soItems#</td>
					</tr>
				</cfif>
			</table>
		</form>
		<cfif StructKeyExists(form,"srchGo")>
			<cfflush interval="200">
			<cfsetting requesttimeout="900">
			<p>Price mark and case qty are the two items missing from the Booker web site data.<br />
			After checking the price mark flags, REFRESH THE PAGE to correct any incorrect prices. Once set, PM flags remain set.<br />
			ONLY THEN should you correct any case quantity errors. Changes are immediate. No need to edit stock manually.</p>
			<cfif StructKeyExists(form,"srchMode")>
				<cfset parm.srchMode = form.srchMode>
				<cfset stockOrder = import.CheckStockOrder(parm)>
				<cfset parm.stockOrderID = stockOrder.stockOrderID>
				<cfset parm.form = form>
				<cfif form.srchMode eq 1>
					<cfset dataImport = import.processFile4(parm)>
					<cfset import.outputData4(dataImport)>
				<cfelseif form.srchMode eq 2>
					<cfset dataImport = import.processFile4(parm)>
					<cfset progress = import.saveData(dataImport)>
					<!---<cfdump var="#progress#" label="progress" expand="false">--->
					<cfset import.outputData4(dataImport)>
				</cfif>
			</cfif>
		</cfif>
	</cfoutput>
</body>
</html>