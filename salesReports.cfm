<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>Stock Sales &amp; Purchase</title>
	<link rel="stylesheet" type="text/css" href="css/main3.css"/>
	<style>
		.sale {color:#FF00FF; line-height:16px;}
		.purch {color:#0000FF; line-height:16px;}
		.group {font-size:24px; font-weight:bold}
		.priceErr {background:#FC0}
		.stkErr {font-size:16px; font-weight:bold; background:#FC0}
		.stkOK {font-size:16px; font-weight:bold}
		.footnote {font-size:11px}
		.tiny {font-size:9px}
		@media print {
			.no-print {display: none !important;}
		}
		.product-line {page-break-inside:avoid;}
	</style>
	<script src="scripts/jquery-1.11.1.min.js"></script>
	<script src="scripts/jquery-ui-1.10.3.custom.min.js"></script>
	<script type="text/javascript">
		$(document).ready(function() {
			var isEditingOpenStock = false;
			$('.openstock').click(function(event) {
				if (!isEditingOpenStock) {
					var value = $(this).html().trim();
					var prodID = $(this).attr("data-id");
					var htmlStr = "<input type='text' size='3' value='" + value + "' class='openstock_input' data-id='" + prodID + "'>";
					$(this).html(htmlStr);
					$(this).find('.openstock_input').focus();
				}
				isEditingOpenStock = true;
			});
			$(document).on("blur", ".openstock_input", function(event) {
				var value = $(this).val();
				var prodID = $(this).attr("data-id");
				var cell = $(this).parent('.openstock');
				$.ajax({
					type: "POST",
					url: "saveProductStockLevel.cfm",
					data: {"stockLevel": value, "prodID": prodID},
					success: function(data) {
						cell.html(data.trim());
						isEditingOpenStock = false;
					}
				});
			});
		});
	</script>
</head>

<cfsetting requesttimeout="900">
<cfparam name="theYear" default="#Year(now())#">
<cfparam name="group" default="151">
<cfparam name="category" default="0">
<cfobject component="code/sales" name="sales">
<cfset parms={}>
<cfset parms.datasource=application.site.datasource1>
<cfset parms.grpID=group>
<cfset parms.catID=category>
<cfset parms.rptYear=theYear>
<cfset QSales = sales.stockSalesByMonth(parms)>
<cfset Purch = sales.stockPurchByMonth(parms)>
<cfset groups = sales.LoadGroups(parms)>
<cfset nonMovers = sales.stockNonMovers(parms)>
<!---
<cfdump var="#QSales#" label="QSales" expand="false">
<cfdump var="#Purch#" label="Purch" expand="false">
<cfdump var="#nonMovers#" label="nonMovers" expand="false">
--->
<body>
<cfoutput>
	<div class="no-print">
		<form method="post" enctype="multipart/form-data">
			Product Group:
			<select name="group" id="group">
				<option value="">Select group...</option>
				<cfloop query="groups.ProductGroups">
				<option value="#pgID#"<cfif parms.grpID eq pgID> selected</cfif>>#pgTitle#</option>
				</cfloop>
			</select>
			<input type="submit" name="btnGo" value="Go">
		</form>
	</div>
	<table class="tableList" border="1">
		<tr>
			<th colspan="4">Stock Movement Report</th>
			<th colspan="17" align="right">as at: #LSDateFormat(now(),"dd-mmm-yyyy")# #LSTimeFormat(now(),'HH:MM')#</th>
		</tr>
		<tr>
			<th>Product<br />Code</th>
			<th>Description</th>
			<th>Size</th>
			<th width="26">Open<br />Stock</th>
			<th width="26" align="right">Jan</th>
			<th width="26" align="right">Feb</th>
			<th width="26" align="right">Mar</th>
			<th width="26" align="right">Apr</th>
			<th width="26" align="right">May</th>
			<th width="26" align="right">Jun</th>
			<th width="26" align="right">Jul</th>
			<th width="26" align="right">Aug</th>
			<th width="26" align="right">Sep</th>
			<th width="26" align="right">Oct</th>
			<th width="26" align="right">Nov</th>
			<th width="26" align="right">Dec</th>
			<th width="26" align="right">Total</th>
			<th width="26" align="center">Close<br />Stock</th>
			<th width="26" align="right">Shop</th>
			<th width="26" align="right">Store</th>
		</tr>
	<cfset categoryID = 0>
	<cfset groupID = 0>
	<cfset groupTotal = 0>
	<cfloop query="QSales.salesItems">
		<cfif groupID neq pgID>
			<tr>
				<th colspan="21"><span class="group">#pgTitle#</span></th>
			</tr>
			<cfset groupID = pgID>
		</cfif>
		<cfif categoryID neq pcatID>
			<cfif groupTotal gt 0>
				<tr>
					<td colspan="17" align="right">Category Total</td>
					<td align="center"><strong>#groupTotal#</strong></td>
					<td></td>
					<td></td>
				</tr>
				<cfset groupTotal = 0>
			</cfif>
			<tr>
				<th colspan="21">#pcatTitle#</th>
			</tr>
			<cfset categoryID = pcatID>
		</cfif>
		<cfif StructKeyExists(Purch.stock,prodID)>
			<cfset purRec = StructFind(Purch.stock,prodID)>
			<cfif IsDate(purRec.prodCountDate) AND Year(purRec.prodCountDate) eq theYear><cfset purRec.total += purRec.prodStockLevel></cfif>
		<cfelse>
			<cfset purRec = {}>
			<cfset purRec.prodPriceMarked = 0>
			<cfset purRec.prodCountDate = CreateDate(theYear,1,1)>
			<cfset purRec.prodStockLevel = prodStockLevel>
			<cfset purRec.total = prodStockLevel>
			<cfloop list="jan,feb,mar,apr,may,jun,jul,aug,sep,oct,nov,dec" index="mnth">
				<cfset StructInsert(purRec,mnth,0)>
			</cfloop>
		</cfif>
		<tr class="product-line">
			<td>#prodID#<br /><span class="tiny">#prodStatus#</span></td>
			<td><a href="productStock6.cfm?product=#prodID#" target="stockcheck">#prodTitle#</a></td>
			<cfif val(siOurPrice) eq 0>
				<cfset class = "priceErr">
			<cfelse>
				<cfset class = "">
			</cfif>
			<td align="center" class="#class#">
				<cfif val(siOurPrice) eq 0>
					&pound; missing
				<cfelse>
					#siUnitSize#<br />
					&pound;#siOurPrice# <span class="tiny">#GetToken(" |PM",val(prodPriceMarked)+1,"|")#</span>
				</cfif>
			</td>
			<td align="center" class="openstock disable-select" data-id="#prodID#">
				<cfif IsDate(purRec.prodCountDate) AND Year(purRec.prodCountDate) eq theYear>#purRec.prodStockLevel#</cfif>
			</td>
			<cfloop list="jan,feb,mar,apr,may,jun,jul,aug,sep,oct,nov,dec" index="mnth">
				<cfset mnthSale = QSales.salesItems[mnth][currentrow]>
				<cfset mnthPurch = 0>
				<cfset mnthPurch = StructFind(purRec,mnth)>
				<td width="26" align="right" class="mnthStk">
					<span class="sale"><cfif mnthSale gt 0>#mnthSale#<cfelse>&nbsp;</cfif><br /></span>
					<span class="purch"><cfif mnthPurch gt 0>#mnthPurch#<cfelse>&nbsp;</cfif></span>
				</td>
			</cfloop>
			<td width="50" align="right">
				<span class="sale">#total#<br /></span>
				<span class="purch">#purRec.total#</span>
			</td>
			<cfset stockTotal = purRec.total - total>
			<cfset groupTotal += stockTotal>
			<cfif stockTotal lt 0>
				<cfset class = "stkErr">
			<cfelse><cfset class = "stkOK"></cfif>
			<td width="50" align="center" class="#class#">#stockTotal#</td>
			<td></td>
			<td></td>
		</tr>
	</cfloop>
	<cfif groupTotal gt 0>
		<tr>
			<td colspan="17" align="right">Category Total</td>
			<td align="center"><strong>#groupTotal#</strong></td>
			<td></td>
			<td></td>
		</tr>
		<cfset groupTotal = 0>
	</cfif>
	</table>
	<cfif nonMovers.productList.recordcount gt 0>
		<table class="tableList" border="1">
			<tr>
				<th colspan="7"><span class="group">Non-Movers</span></th>
			</tr>
			<tr>
				<th>Category</th>
				<th>Product<br />Code</th>
				<th>Product</th>
				<th>Size</th>
				<th>Purchased</th>
				<th>Stock Level</th>
				<th>Date Counted</th>
			</tr>
			<cfloop query="nonMovers.productList">
				<tr>
					<td>#pcatTitle#</td>
					<td>#prodID#</td>
					<td><a href="productStock6.cfm?product=#prodID#" target="stockcheck">#prodTitle#</a></td>
					<td align="center">
						#siUnitSize#<br />
						&pound;#siOurPrice# <span class="tiny">#GetToken(" |PM",val(prodPriceMarked)+1,"|")#</span>
					</td>
					<td align="right">#LSDateFormat(soDate,'dd-mmm-yyyy')#</td>
					<td align="center" class="openstock disable-select" data-id="#prodID#">#prodStockLevel#</td>
					<td align="right">#LSDateFormat(prodCountDate,'dd-mmm-yyyy')#</td>
				</tr>
			</cfloop>
		</table>
	</cfif>
	<table class="footnote">
		<tr>
			<td>
				<table>
					<tr><th colspan="2">Negative opening stock is caused by:-</th></tr>
					<tr><td>1</td><td>Stock not sold through till, e.g taken for Bunnery or home.</td></tr>
					<tr><td>2</td><td>Incorrect product assigned with the received stock.</td></tr>
					<tr><td>3</td><td>Theft.</td></tr>
					<tr><td class="stkErr"></td><td>Errors are marked in yellow.</td></tr>
				</table>
			</td>
			<td>
				<table>
					<tr><th colspan="2">Negative closing stock is caused by:-</th></tr>
					<tr><td>1</td><td>Product received but not booked in.</td></tr>
					<tr><td>2</td><td>Wrong product booked in.</td></tr>
					<tr><td>3</td><td>Opening stock figure not declared.</td></tr>
					<tr><td>&nbsp;</td><td></td></tr>
				</table>
			</td>
		</tr>
	</table>
</cfoutput>
</body>
</html>
