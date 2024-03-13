<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>Stock Sales &amp; Purchase</title>
	<link rel="stylesheet" type="text/css" href="css/main3.css" />
	<link rel="stylesheet" type="text/css" href="css/chosen.css" />
	<link rel="stylesheet" type="text/css" href="css/jquery-ui-1.10.3.custom.min.css">
	<style>
		.sale {color:#FF00FF; line-height:16px;}
		.purch {color:#0000FF; line-height:16px;}
		.group {font-size:24px; font-weight:bold}
		.priceErr {background:#FC0}
		.stkErr {font-size:16px; font-weight:bold; background:#FC0}
		.stkOK {font-size:16px; font-weight:bold}
		.footnote {font-size:11px}
		.tiny {font-size:9px}
		.sod_status {background-color:#9CF; padding:2px; margin:2px; height:20px}
		@media print {
			.no-print {display: none !important;}
		}
		.product-line {page-break-inside:avoid;}
	</style>
	<script src="scripts/jquery-1.11.1.min.js"></script>
	<script src="scripts/jquery-ui-1.10.3.custom.min.js"></script>
	<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
	<script type="text/javascript">
		$(document).ready(function() {
			var isEditingOpenStock = false;
			$(".srchStatus").chosen({width: "300px"});
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
			$('.datepicker').datepicker({dateFormat: "yy-mm-dd",changeMonth: true,changeYear: true,showButtonPanel: true, minDate: new Date(2018, 10 - 1, 29)});
			$('.sod_status').click(function(event) {
				var value = $(this).html();
				var prodID = $(this).attr("data-id");
				var cell = $(this);
				$.ajax({
					type: "POST",
					url: "saveProductStatus.cfm",
					data: {"status": value, "prodID": prodID},
					success: function(data) {
						cell.html(data.trim());
						cell.css("color",'red');
						cell.css("font-weight",'bold');
					}
				});
			});
		});
	</script>
</head>

<cfsetting requesttimeout="900">
<cfparam name="theYear" default="#Year(now())#">
<cfparam name="group" default="0">
<cfparam name="category" default="0">
<cfparam name="srchDateFrom" default="#DateFormat(CreateDate(Year(now()),1,1),'yyyy-mm-dd')#">
<cfparam name="srchDateTo" default="#DateFormat(Now(),'yyyy-mm-dd')#">
<cfparam name="srchStatus" default="">
<cfparam name="srchCloseStock" default="">
<!---<cfset timespan = DateDiff("d",srchDateFrom,srchDateTo)>
<cfif timespan lt 180>
	<cfset dateFrom = DateAdd("d",-180,Now())>
	<cfset srchDateFrom = DateFormat(CreateDate(Year(dateFrom),Month(dateFrom),1),'yyyy-mm-dd')>
</cfif>--->
<cfobject component="code/sales" name="sales">
<cfset parms={}>
<cfset parms.datasource=application.site.datasource1>
<cfset parms.grpID=group>
<cfset parms.catID=category>
<cfset parms.rptYear=theYear>
<cfset parms.srchDateFrom = srchDateFrom>
<cfset parms.srchDateTo = srchDateTo>
<cfset parms.srchStatus = srchStatus>
<cfset parms.srchCloseStock = srchCloseStock>
	
<cfset groups = sales.LoadGroups(parms)>
<cfset prodStatusTitles = "active,inactive,donotbuy">

<body>
<cfoutput>
	<div class="no-print">
		<form method="post" enctype="multipart/form-data">
		<div class="module no-print">
			<table border="0">
				<tr>
					<td><b>Product Group:</b></td>
					<td>
						<select name="group" id="group">
							<option value="">Select group...</option>
							<cfloop query="groups.ProductGroups">
							<option value="#pgID#"<cfif parms.grpID eq pgID> selected</cfif>>#pgTitle#</option>
							</cfloop>
						</select>
					</td>
				</tr>
				<tr>
					<td><b>Date From</b></td>
					<td>
						<input type="text" name="srchDateFrom" value="#srchDateFrom#" class="datepicker" />
					</td>
				</tr>
				<tr>
					<td><b>Date To</b></td>
					<td>
						<input type="text" name="srchDateTo" value="#srchDateTo#" class="datepicker" />
					</td>
				</tr>
				<tr>
					<td><b>Stock Status</b></td>
					<td>
						<select name="srchStatus" class="srchStatus" multiple="multiple" data-placeholder="Select...(optional)">
							<cfloop list="#prodStatusTitles#" index="i" delimiters=",">
								<option value="#i#"<cfif ListFind(srchStatus,i)> selected="selected"</cfif>>#i#</option>
							</cfloop>
						</select>									
					</td>
				</tr>
				<tr>
					<td><b>Ignore Zero Stock</b></td>
					<td>
						<input type="checkbox" name="srchCloseStock" value="1" <cfif StructKeyExists(form,"srchCloseStock")>checked</cfif> />
					</td>
				</tr>
				<tr>
					<td colspan="2"><input type="submit" name="btnGo" value="Go"></td>
				</tr>
			</table>
		</div>			
		</form>
	</div>

	<cfif group neq 0>
   		<cfdump var="#parms#" label="parms" expand="false">
		<cfset products = sales.selectProducts(parms)>
		<cfdump var="#products#" label="products" expand="false">
		<table class="tableList" border="1">
			<cfif StructKeyExists(form,"srchShowQuery")>
				<tr>
					<td colspan="25">#ParagraphFormat(products.productListResult.sql)#</td>
				</tr>
			</cfif>
			<tr>
				<th colspan="4">Stock Movement Report</th>
				<th colspan="21" align="left">as at: #LSDateFormat(now(),"dd-mmm-yyyy")# #LSTimeFormat(now(),'HH:MM')#</th>
			</tr>
			<tr>
				<th width="60">Product<br />Code</th>
				<th>ID</th>
				<th>Description</th>
				<th>Size</th>
				<th width="26">Open<br />Stock</th>
				<th width="26">S<br />P</th>
				<th width="26">BFwd</th>
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
				<th width="26" align="right">Year<br />Total</th>
				<th width="26" align="center">Overall<br />Total</th>
				<th width="26" align="center">Close<br />Stock</th>
				<th width="26" align="right">Retail<br />Value</th>
				<th width="26" align="right">Gross<br />Trade</th>
				<th width="26" align="right">Shop</th>
				<th width="26" align="right">Store</th>
			</tr>
			<cfset categoryID = 0>
			<cfset groupID = 0>
			<cfset categoryTotal = 0>
			<cfset retailTotal = 0>
			<cfset retailGrandTotal = 0>
			<cfset tradeTotal = 0>
			<cfset tradeGrandTotal = 0>
			<cfset POR = 0>
			<cfloop query="products.productList">
				<cfif groupID neq pgID>
					<tr>
						<th colspan="25"><span class="group">#pgTitle#</span></th>
					</tr>
					<cfset groupID = pgID>
				</cfif>
				<cfif categoryID neq pcatID>
					<cfif categoryTotal neq 0>
						<tr>
							<td colspan="20" align="right">Category Total</td>
							<td align="right"><strong>#categoryTotal#</strong></td>
							<td align="right"><strong>#DecimalFormat(retailTotal)#</strong></td>
							<td align="right"><strong>#DecimalFormat(tradeTotal)#</strong></td>
							<cfset profit = retailTotal - tradeTotal>
							<cfset POR = (profit / retailTotal) * 100>
							<td align="right"><strong>#DecimalFormat(profit)#</strong></td>
							<td align="right"><strong>#DecimalFormat(POR)#%</strong></td>
						</tr>
						<cfset retailGrandTotal += retailTotal>
						<cfset tradeGrandTotal += tradeTotal>
						<cfset categoryTotal = 0>
						<cfset retailTotal = 0>
						<cfset tradeTotal = 0>
					</cfif>
					<tr>
						<th colspan="25">#pcatTitle#</th>
					</tr>
					<cfset categoryID = pcatID>
				</cfif>
				<tr class="product-line">
					<td>#prodRef#<br />
						<span class="sod_status disable-select" data-id="#prodID#">#prodStatus#</span>
					</td>
                    <td>#prodID#</td>
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
					<td align="center" class="openstock disable-select" data-id="#prodID#">#prodStockLevel#</td>
					<cfset sData = {}>
					<cfset pData = {}>
					<cfif StructKeyExists(products.SalesData,prodID)>
						<cfset sData = StructFind(products.SalesData,prodID)>
					</cfif>
					<cfif StructKeyExists(products.PurchData,prodID)>
						<cfset pData = StructFind(products.PurchData,prodID)>
					</cfif>
					<td width="50" align="right">
						<span class="sale">#val(sData.BFwd)#</span><br /><span class="purch">#val(pData.BFwd)#</span>
					</td>
					<cfset openStock = prodStockLevel + val(pData.BFwd) - val(sData.BFwd)>
					<td>#openStock#</td>
					<cfloop list="jan,feb,mar,apr,may,jun,jul,aug,sep,oct,nov,dec" index="mnth">
						<td width="26" align="right" class="mnthStk">
							<cfset sMnth = 0>
							<cfif StructKeyExists(sData,mnth)>
								<cfset sMnth = StructFind(sData,mnth)>
							</cfif>
							<cfset pMnth = 0>
							<cfif StructKeyExists(pData,mnth)>
								<cfset pMnth = StructFind(pData,mnth)>
							</cfif>
							<span class="sale"><cfif sMnth neq 0>#sMnth#<cfelse>&nbsp;</cfif><br /></span>
							<span class="purch"><cfif pMnth neq 0>#pMnth#<cfelse>&nbsp;</cfif></span>
						</td>
					</cfloop>
					<td width="50" align="right">
						<span class="sale">#sData.total#<br /></span>
						<span class="purch">#pData.total#</span>
					</td>
					<td width="50" align="right">
						<span class="sale">#val(sData.BFwd) + sData.total#</span><br />
						<span class="purch">#prodStockLevel + val(pData.BFwd) + pData.total#</span>
					</td>
					<cfset closeStock = openStock + val(pData.total) - val(sData.total)>
					<cfset categoryTotal += closeStock>
					<cfif closeStock lt 0>
						<cfset class = "stkErr">
					<cfelse><cfset class = "stkOK"></cfif>
					<td width="50" align="right" class="#class#">#closeStock#</td>
					<cfset retailValue = closeStock * siOurPrice>
					<cfset retailTotal += retailValue>
					<td align="right">#DecimalFormat(retailValue)#</td>
					<cfset tradeValue = closeStock * (siUnitTrade * (1 + (prodVATRate /100)))>
					<cfset tradeTotal += tradeValue>
					<td align="right">#DecimalFormat(tradeValue)#</td>
					<td></td>
					<td></td>
				</tr>
			</cfloop>
			<cfif categoryTotal neq 0>
				<tr>
					<td colspan="20" align="right">Category Total</td>
					<td align="right"><strong>#categoryTotal#</strong></td>
					<td align="right"><strong>#DecimalFormat(retailTotal)#</strong></td>
					<td align="right"><strong>#DecimalFormat(tradeTotal)#</strong></td>
					<cfset profit = retailTotal - tradeTotal>
					<cfset POR = (profit / retailTotal) * 100>
					<td align="right"><strong>#DecimalFormat(profit)#</strong></td>
					<td align="right"><strong>#DecimalFormat(POR)#%</strong></td>
				</tr>
			</cfif>
			<tr>
				<td colspan="20" align="right">Grand Total</td>
				<td align="right"></td>
				<td align="right"><strong>#DecimalFormat(retailGrandTotal)#</strong></td>
				<td align="right"><strong>#DecimalFormat(tradeGrandTotal)#</strong></td>
				<cfset profit = retailGrandTotal - tradeGrandTotal>
				<cfif retailGrandTotal neq 0><cfset POR = (profit / retailGrandTotal) * 100></cfif>
				<td align="right"><strong>#DecimalFormat(profit)#</strong></td>
				<td align="right"><strong>#DecimalFormat(POR)#%</strong></td>
			</tr>
		</table>
		<div class="no-print">
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
		</div>
	</cfif>	
	
	
<!---	
	
	
	<h1> old version </h1>
	
<cfif group neq 0>
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
			<th width="26">S /<br />P</th>
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
	<cfset categoryTotal = 0>
	<cfloop query="SalesData.salesItems">
		<cfif groupID neq pgID>
			<tr>
				<th colspan="21"><span class="group">#pgTitle#</span></th>
			</tr>
			<cfset groupID = pgID>
		</cfif>
		<cfif categoryID neq pcatID>
			<cfif categoryTotal gt 0>
				<tr>
					<td colspan="18" align="right">Category Total</td>
					<td align="center"><strong>#categoryTotal#</strong></td>
					<td></td>
					<td></td>
				</tr>
				<cfset categoryTotal = 0>
			</cfif>
			<tr>
				<th colspan="21">#pcatTitle#</th>
			</tr>
			<cfset categoryID = pcatID>
		</cfif>
		<cfif StructKeyExists(PurchData.stock,prodID)>
			<cfset purRec = StructFind(PurchData.stock,prodID)>
			<!---<cfif IsDate(purRec.prodCountDate) AND Year(purRec.prodCountDate) eq theYear>---><cfset purRec.total += purRec.prodStockLevel><!---</cfif>--->
		<cfelse>
			<cfset purRec = {}>
			<cfset purRec.prodPriceMarked = 0>
			<cfset purRec.prodCountDate = CreateDate(theYear,1,1)>
			<cfset purRec.prodStockLevel = prodStockLevel>
			<cfset purRec.BFwd = 0>
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
				#prodStockLevel#
			</td>
			<td align="center">
				<!---<cfif IsDate(purRec.prodCountDate) AND Year(purRec.prodCountDate) eq theYear>#purRec.prodStockLevel#</cfif>--->
				<cfset openStock = purRec.prodStockLevel>
				<!---<cfset openStock = val(purRec.BFwd) - val(SalesData.salesItems.BFwd)>--->
				<span class="sale">#val(SalesData.salesItems.BFwd)#</span> <br /> <span class="purch">#val(purRec.BFwd)#</span>
			</td>
			<cfloop list="jan,feb,mar,apr,may,jun,jul,aug,sep,oct,nov,dec" index="mnth">
				<cfset mnthSale = SalesData.salesItems[mnth][currentrow]>
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
			<cfset stockTotal = purRec.total - total + openStock>
			<cfset categoryTotal += stockTotal>
			<cfif stockTotal lt 0>
				<cfset class = "stkErr">
			<cfelse><cfset class = "stkOK"></cfif>
			<td width="50" align="center" class="#class#">#stockTotal#</td>
			<td></td>
			<td></td>
		</tr>
	</cfloop>
	<cfif categoryTotal gt 0>
		<tr>
			<td colspan="18" align="right">Category Total</td>
			<td align="center"><strong>#categoryTotal#</strong></td>
			<td></td>
			<td></td>
		</tr>
		<cfset categoryTotal = 0>
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
</cfif>
--->

</cfoutput>
</body>
</html>
