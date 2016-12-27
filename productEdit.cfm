<!DOCTYPE html>
<html>
<head>
	<title>Product Edit</title>
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
	<script src="scripts/productStockTake.js" type="text/javascript"></script>
	<script src="scripts/stock.js" type="text/javascript"></script>	
	<script type="text/javascript">
		$(document).ready(function() {
			$('.updateCal').change(function(event) {
				Calculate();
			});
			Calculate();
		});
	</script>

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
		#prodOurPrice {font-size:24px; font-weight:bold; margin-top:10px;}
		#RRPPOR {font-size:18px; font-weight:bold;}
	</style>
</head>
<!---<cfdump var="#form#" label="form" expand="yes">--->
<body>
	<h1>Edit Product</h1>
	<cftry>	
		<cfif StructKeyExists(url,"ref")>
			<cfobject component="code/ProductStock5" name="pstock">
			<cfset parm={}>
			<cfset parm.prodID=url.ref>
			<cfset parm.datasource=application.site.datasource1>
			<cfset parm.url = application.site.normal>
			<cfif StructKeyExists(form,"fieldnames")>
				<cfset parm.form = form>
				<cfset pstock.ProductUpdate(parm)>
				<cflocation url="#cgi.SCRIPT_NAME#?ref=#parm.prodID#" addtoken="no">
			</cfif>
			<cfset lookup=pstock.ProductDetails(parm)>
			<cfset suppliers=pstock.LoadSuppliers(parm)>
			<!---<cfdump var="#lookup#" label="lookup" expand="no">--->
	
			<cfoutput>
				<div id="entryForm">
					<cfif lookup.QOrders.recordcount gt 0>
						<cfset stockItemID = lookup.QOrders.siID>
					<cfelse>
						<cfset stockItemID = 0>
					</cfif>
					<cfloop query="lookup.QProduct">
						<cfset priceMarked = prodPriceMarked>
						<cfset supplierID = prodSuppID>
					<form name="ProductForm" id="ProductForm" method="post" enctype="multipart/form-data">
						<input type="hidden" name="prodID" value="#prodID#" />
						<input type="hidden" name="stockItemID" value="#stockItemID#" />
						<input type="hidden" name="hProdOurMarkup" id="hProdOurMarkup" value="" />
						<input type="hidden" name="hRRPPOR" id="hRRPPOR" value="" />
						<input type="hidden" name="hprodOurPrice" id="hprodOurPrice" value="" />
						<table border="1" class="tableList" width="600">
							<tr>
								<td>Supplier</td>
								<td colspan="3">
									<select name="prodSuppID" tabindex="1">
										<option value="0">select...</option>
										<cfloop query="suppliers">
											<option value="#accID#"<cfif supplierID eq accID> selected="selected"</cfif>>#accName#</option>
										</cfloop>
									</select>
								</td>
							</tr>
							<tr><td>Reference</td><td colspan="3"><input type="text" name="prodRef" id="prodRef" size="15" value="#prodRef#" tabindex="2" /></td></tr>
							<tr><td>Record Title</td><td colspan="3"><input type="text" name="prodRecordTitle" id="prodRecordTitle" size="30" value="#prodRecordTitle#" tabindex="3" /></td></tr>
							<tr><td>Public Title</td><td colspan="3"><input type="text" name="prodTitle" id="prodTitle" size="30" value="#prodTitle#" tabindex="4" /></td></tr>
							<tr>
								<td>Unit Size</td><td><input type="text" name="prodUnitSize" id="prodUnitSize" size="10" value="#prodUnitSize#" tabindex="5" /></td>
								<td>Our Markup</td><td><input type="text" name="prodOurMarkup" class="updateCal" id="prodOurMarkup" size="10" value="#prodOurMarkup#" /></td>
							</tr>
							<tr>
								<td>Units per Pack</td><td><input type="text" name="prodPackQty" class="updateCal" id="prodPackQty" class="qtys" size="10" value="#prodPackQty#" tabindex="6" /></td>
								<td>Pack Price (WSP)</td><td><input type="text" name="prodPackPrice" class="updateCal" id="prodPackPrice" size="10" value="#prodPackPrice#" /></td>
							</tr>
							<tr>
								<td>RRP</td><td><input type="text" name="prodRRP" class="updateCal" id="prodRRP" size="10" value="#prodRRP#" tabindex="7" /></td>
								<td>Our Price</td><td><span id="prodOurPrice">&pound;#prodOurPrice#</span></td>
							</tr><!---<input type="text" name="prodOurPrice" class="updateCal" id="prodOurPrice" size="10" value="#prodOurPrice#" />--->
							<tr>
								<td>VAT Rate</td>
								<td>
									<select name="prodVATRate" id="prodVATRate" class="updateCal" tabindex="8">
										<option value="" <cfif prodVATRate eq "">selected</cfif>>select...</option>
										<option value="0.000" <cfif prodVATRate eq "0.000">selected</cfif>>0.00%</option>
										<option value="20.000" <cfif prodVATRate eq "20.000">selected</cfif>>20.00%</option>
										<option value="5.000" <cfif prodVATRate eq "5.000">selected</cfif>>5.00%</option>
									</select>
								</td>
								<td>POR</td><td><span id="RRPPOR">#prodPOR#%</span></td>
							</tr>
							<tr>
								<td>Price Marked</td>
								<td><input type="checkbox" name="prodPriceMarked" id="prodPriceMarked" class="updateCal" notab <cfif prodPriceMarked>checked</cfif> /></td>
								<td>Stock as at #LSDateFormat(prodCountDate)#</td>
								<td><input type="text" name="prodStockLevel" id="prodStockLevel" disabled size="10" value="#prodStockLevel#" /></td>
							</tr>
							
<!---							<tr><td>Purchase Date</td><td><input type="text" name="soDate" id="soDate" size="10" class="datepicker" value="#soDate#" /></td></tr>
							<tr><td>Expiry Date</td><td><input type="text" name="siExpires" size="10" class="datepicker" value="#siExpires#" /></td></tr>
							<tr><td>No. Outer Packs</td><td><input type="text" name="siQtyPacks" id="siQtyPacks" class="qtys" size="10" value="#siQtyPacks#" /></td></tr>
							<tr><td>Items in Stock</td><td><input type="text" name="siQtyItems" id="siQtyItems" size="10" value="#siQtyItems#" /></td></tr>
--->
							<tr><td colspan="4" height="40"><input type="submit" name="btnSubmit" id="btnSubmit" value="Save Changes" /></td></tr>
						</table>
					</form>
					</cfloop>
				</div>
				<div id="ordersDiv">
					<table border="1" class="tableList" width="600">
						<tr>
							<th class="headleft">##</th>
							<th class="headleft">Order</th>
							<th class="headleft">Order <br />Status</th>
							<th class="headleft">Date</th>
							<th class="headleft">No. Packs</th>
							<th class="headright">WSP</th>
							<th class="headright">Unit</th>
							<th class="headright">RRP</th>
							<th class="headright">Our Price</th>
							<th class="headright">POR</th>
							<th class="headright">Item <br />Status</th>
							<th class="headright">Booked In</th>
						</tr>
						<cfloop query="lookup.QOrders">
						<tr>
							<td>#currentrow#</td>
							<td>#soRef#</td>
							<td>#soStatus#</td>
							<td>#LSDateFormat(soDate)#</td>
							<td align="center">#siQtyPacks#</td>
							<td align="right">#siWSP#</td>
							<td align="right">#siUnitTrade#</td>
							<td align="right">#siRRP#</td>
							<td align="right">#siOurPrice# <cfif priceMarked>PM</cfif></td>
							<td align="right">#siPOR#%</td>
							<td align="right">#siStatus#</td>
							<td align="right">#siBookedIn#</td>
						</tr>
						</cfloop>
					</table>
				</div>
				<div id="barcodeDiv">
					<br>
					<table class="tableList" width="500">
						<tr>
							<th>Record ID</th>
							<th>Barcode</th>
							<th>Options</th>
						</tr>
						<cfif lookup.QBarcodes.recordcount gt 0>
							<cfloop query="lookup.QBarcodes">
								<tr>
									<td>#barID#</td>
									<td>#barcode#</td>
									<td><a href="?removeID=#barID#">remove this barcode</a></td>
								</tr>
							</cfloop>
						<cfelse>
							This product has no barcode records.
						</cfif>
						<form name="addcode" method="post">
							<input type="hidden" name="prodID" value="#parm.prodID#" />
						<tr>
							<td>New Code: </td>
							<td><input type="text" name="newCode" id="newCode" size="16" maxlength="13" /></td>
							<td><input type="submit" name="btnAdd" value="Add Barcode" /></td>
						</tr>
						</form>
						<tr>
							<td colspan="3">Place cursor in the <b>New Code</b> box and scan the product.</td>
						</tr>
					</table>
				</div>
			
			</cfoutput>
		<cfelse>
			No product ID specified.
		</cfif>
		
	<cfcatch type="any">
		<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
	</cfcatch>
	</cftry>

</body>
</html>
