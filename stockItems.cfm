<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>Stock Items</title>
	<link rel="stylesheet" type="text/css" href="css/main.css"/>
	<style type="text/css">
		.priceDiff {background-color:#FADCD8;}
		.priceMatch {background-color:#fff;}
		.header {font-size:14px; font-weight:bold;}
		.headleft {text-align:left; font-size:12px;}
		.headright {text-align:right; font-size:12px;}
		#barcodeDiv {margin-top:30px;}
		.tableList {font-size:16px;}
	</style>
</head>

<cftry>
<cfset msg="">
<cfparam name="ref" default="">
<cfobject component="code/stock" name="stock">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.ref=ref>

<cfif StructKeyExists(form,"fieldnames")>
	<cfset parm.form=form>
	<cfset addCode=stock.AddProductBarcode(parm)>
	<cfset msg=addCode.msg>
</cfif>

<cfif StructKeyExists(url,"removeID")>
	<cfset parm.ID=val(url.removeID)>
	<cfset removeCode=stock.DeleteProductBarcode(parm)>
	<cfset msg=removeCode.msg>
</cfif>

<cfset records=stock.StockItemList(parm)>
<cfset codes=stock.ProductBarcodes(parm)>

<body>
	<cfoutput>
		<table width="900" border="1" class="tableList">
			<cfif records.recordcount IS 0>
				<tr>
					<td colspan="14" style="background-color:##eeeeee">No stock items found for #ref#.</td>
				</tr>				
			<cfelse>
				<tr>
					<td colspan="14" style="background-color:##eeeeee">
						<table class="tableList" width="100%" border="0">
							<tr>
								<td><a href="http://tweb.sle-admin.co.uk/productStock6.cfm?product=#parm.ref#">#parm.ref#</a></td>
								<td>#records.stockItems.prodRef#</td>
								<td>#records.stockItems.prodTitle#</td>
								<td>Last Bought: #DateFormat(records.stockItems.prodLastBought,"dd-mmm-yyyy")#</td>
								<td>&pound;#records.stockItems.prodOurPrice#</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<th class="headleft">##</th>
					<th class="headleft">siID</th>
					<th class="headleft">Order</th>
					<th class="headleft">Order <br />Status</th>
					<th class="headleft">Date</th>
					<th class="headleft">No. Packs</th>
					<th class="headleft">Pack Qty</th>
					<th class="headleft">Stock Level</th>
					<th class="headright">WSP</th>
					<th class="headright">Unit</th>
					<th class="headright">RRP</th>
					<th class="headright">Our Price</th>
					<th class="headright">POR</th>
					<th class="headright">Item <br />Status</th>
				</tr>
				<cfloop query="records.stockItems">
				<tr>
					<td>#currentrow#</td>
					<td>#siID#</td>
					<td>#soRef#</td>
					<td>#soStatus#</td>
					<td>#LSDateFormat(soDate)#</td>
					<td align="center">#siQtyPacks#</td>
					<td align="center">#prodPackQty#</td>
					<td align="center">#prodStockLevel#</td>
					<td align="right">#siWSP#</td>
					<td align="right">#siUnitTrade#</td>
					<td align="right">#siRRP#</td>
					<td align="right">#siOurPrice# <cfif prodPriceMarked>PM</cfif></td>
					<td align="right">#siPOR#%</td>
					<td align="right">#siStatus#</td>
				</tr>
				</cfloop>
			</cfif>
		</table>
		<div id="barcodeDiv">
				<table class="tableList" width="500">
					<tr>
						<th>Record ID</th>
						<th>Barcode</th>
						<th>Options</th>
					</tr>
					<cfif ArrayLen(codes.barcodes)>
						<cfloop array="#codes.barcodes#" index="item">
							<tr>
								<td>#item.ID#</td>
								<td>#item.code#</td>
								<td><a href="?ref=#ref#&amp;removeID=#item.ID#">remove this barcode</a></td>
							</tr>
						</cfloop>
					<cfelse>
						This product has no barcode records.
					</cfif>
					<form name="addcode" method="post">
						<input type="hidden" name="prodID" value="#parm.ref#" />
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
			<h1>#msg#</h1>
		</div>
	</cfoutput>
</body>
</html>
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>

