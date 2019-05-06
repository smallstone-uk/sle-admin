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
<cfparam name="group" default="31">
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
			<th>Stock Movement Report <br />#LSDateFormat(now(),"dd-mmm-yyyy")#</th>
			<th>Size</th>
			<th width="30">Open<br />Stock</th>
			<th width="30" align="right">Jan</th>
			<th width="30" align="right">Feb</th>
			<th width="30" align="right">Mar</th>
			<th width="30" align="right">Apr</th>
			<th width="30" align="right">May</th>
			<th width="30" align="right">Jun</th>
			<th width="30" align="right">Jul</th>
			<th width="30" align="right">Aug</th>
			<th width="30" align="right">Sep</th>
			<th width="30" align="right">Oct</th>
			<th width="30" align="right">Nov</th>
			<th width="30" align="right">Dec</th>
			<th width="30" align="right">Total</th>
			<th width="30" align="right">Close<br />Stock</th>
		</tr>
	<cfset categoryID = 0>
	<cfset groupID = 0>
	<cfloop query="QSales.salesItems">
		<cfif groupID neq pgID>
			<tr>
				<th colspan="17"><span class="group">#pgTitle#</span></th>
			</tr>
			<cfset groupID = pgID>
		</cfif>
		<cfif categoryID neq pcatID>
			<tr>
				<th colspan="17">#pcatTitle#</th>
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
			<td><a href="productStock6.cfm?product=#prodID#" target="stockcheck">#prodTitle# (#prodID#)</a></td>
			<td align="center">
				#siUnitSize#<br />
				&pound;#siOurPrice# <span class="tiny">#GetToken(" |PM",val(prodPriceMarked)+1,"|")#</span>
			</td>
			<td align="center" class="openstock disable-select" data-id="#prodID#">
				<cfif IsDate(purRec.prodCountDate) AND Year(purRec.prodCountDate) eq theYear>#purRec.prodStockLevel#</cfif>
			</td>
			<cfloop list="jan,feb,mar,apr,may,jun,jul,aug,sep,oct,nov,dec" index="mnth">
				<cfset mnthSale = QSales.salesItems[mnth][currentrow]>
				<cfset mnthPurch = 0>
				<cfset mnthPurch = StructFind(purRec,mnth)>
				<td width="30" align="right" class="mnthStk">
					<span><cfif mnthSale gt 0>#mnthSale#<cfelse>&nbsp;</cfif><br /></span>
					<span><cfif mnthPurch gt 0>#mnthPurch#<cfelse>&nbsp;</cfif></span>
				</td>
			</cfloop>
			<td width="50" align="right">
				<span class="sale">#total#<br /></span>
				<span class="purch">#purRec.total#</span>
			</td>
			<td width="50" align="right" class="stkTotal">#purRec.total - total#</td>
		</tr>
	</cfloop>
	</table>
	
	<table class="tableList" border="1">
		<tr>
			<th colspan="6"><span class="group">Non-Movers</span></th>
		</tr>
		<tr>
			<th>Category</th>
			<th>Product</th>
			<th>Size</th>
			<th>Purchased</th>
			<th>Stock Level</th>
			<th>Date Counted</th>
		</tr>
		<cfloop query="nonMovers.productList">
			<tr>
				<td>#pcatTitle#</td>
				<td><a href="productStock6.cfm?product=#prodID#" target="stockcheck">#prodTitle# (#prodID#)</a></td>
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
</cfoutput>
</body>
</html>
