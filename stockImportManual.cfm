<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Import Manual Booker Order</title>
<link href="css/main4.css" rel="stylesheet" type="text/css">
<style>
	.red {color:#FF0000;}
	.blue {color:#00F;}
	.header {background-color:#CCCCCC;}
	.tranheader {background-color:#eee;}
	input[type="submit"]{float: left; clear:both;}
</style>
</head>
<body>
<p>This routine creates a manual order from the items stored on the product list.</p>

<cfset loc = {}>
<cfset loc.supplierID = 21>
<cfset loc.orderRef = "#DateFormat(Now(),'yyyymmdd')#">
<cfset loc.orderDate = DateFormat(Now(),'yyyy-mm-dd')>
<cfset loc.validTo="">
<cfset loc.datasource = application.site.datasource1>
<cfobject component="code/ProductStock6" name="pstock">
<cfobject component="code/import2" name="import">
<cfparam name="doImport" default="false">
<cfif !doImport>
	<div>
		<form action="stockImportManual.cfm" method="POST" enctype="multipart/form-data">
			<input type="hidden" name="doImport" value="true" />
			<input type="submit" value="Run process" />
		</form>
	</div>
	<div style="clear:both"></div>
</cfif>
	<cfquery name="getStockListFromDB" datasource="#loc.datasource#">
		SELECT ctlStockList
		FROM tblControl
		WHERE ctlID = 1
	</cfquery>
	<cfset loc.stocklist = getStockListFromDB.ctlStockList>

	<cfset CheckStockOrder=import.CheckStockOrder(loc)>
	<cfset loc.stockOrderID=CheckStockOrder.stockOrderID>
	
	<cfif len(loc.stocklist)>
		<table class="tableList">
		<cfset data = pstock.LoadStockFromList(loc)>
		<cfoutput>
			<tr>
				<th>#CheckStockOrder.orderRef#</th>
			</tr>
			<cfset loopCount = 0>
			<cfloop query="data.stockItems">
				<cfset loopCount++>
				<cfset IIf(siQtyPacks eq 0,1,siQtyPacks)>
				<cfquery name="loc.stockItemExists" datasource="#loc.datasource#">
					SELECT siID
					FROM tblStockItem
					WHERE siOrder=#loc.stockOrderID#
					AND siProduct=#prodID#
					LIMIT 1;
				</cfquery>
				<cfif loc.stockItemExists.recordcount eq 1>
					<tr><td>Stock Item found #loc.stockItemExists.siID# for product ID #prodID#</td></tr>
				<cfelse>
					<cfif doImport>
						<tr><td>inserting #prodID#...</td></tr>
						<cfquery name="loc.stockItemInsert" datasource="#loc.datasource#" result="loc.stockItemInsertResult">
							INSERT INTO tblStockItem (siOrder,siProduct,siQtyPacks,siWSP,siUnitTrade,siRRP,siOurPrice,siPOR,siStatus,siUnitSize,siPackQty,siRef) 
							VALUES (#loc.stockOrderID#,#prodID#,#siQtyPacks#,#siWSP#,#siUnitTrade#,#siRRP#,#siOurPrice#,#siPOR#,'open','#siUnitSize#',#siPackQty#,'#siRef#')
						</cfquery>
						<cfif loc.stockItemInsertResult.generatedKey gt 0>
							<tr><td>Insert successful for #prodID#</td></tr>
						</cfif>
					<cfelse>
						<tr><td>
						INSERT INTO tblStockItem <br />
						(siOrder,siProduct,siQtyPacks,siWSP,siUnitTrade,siRRP,siOurPrice,siPOR,siStatus,siUnitSize,siPackQty,siRef)  <br />
						VALUES (#loc.stockOrderID#,#prodID#,#siQtyPacks#,#siWSP#,#siUnitTrade#,#siRRP#,#siOurPrice#,#siPOR#,'open','#siUnitSize#',#siPackQty#,'#siRef#') <br />				
						</td></tr>
					</cfif>
				</cfif>
			</cfloop>
			<tr>
				<th>#loopCount# records imported.</th>
			</tr>
		</cfoutput>
		</table>
	</cfif>
</body>
</html>