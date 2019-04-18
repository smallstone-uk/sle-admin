<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Fix Stock Items</title>
<style>
	.red {color:#FF0000;}
</style>
</head>
<cfparam name="doUpdate" default="false">
<body>
<h1>Stock Item Cleanup</h1>
<p>Repairs zero pack quantities. Recalculates QtyItems</p>
<cftry>
	<cfif doUpdate>
		<!--- Fix packQty if zero only if items and qtypack gt zero --->
		<cfquery name="QFixStockItems1" datasource="#application.site.datasource1#">
			UPDATE tblStockItem
			SET siPackQty = siQtyItems / siQtyPacks
			WHERE siPackQty = 0
			AND siQtyItems > 0
			AND siQtyPacks > 0
		</cfquery>
		<!--- copy missing data for remaining items where packqty still zero --->
		<cfquery name="QFixStockItems2" datasource="#application.site.datasource1#">
			UPDATE tblStockItem
			INNER JOIN tblStockOrder ON soID=siOrder
			INNER JOIN tblproducts ON prodID=siProduct
			SET
				siPackQty = prodPackQty,
				siUnitSize = prodUnitSize
			WHERE siPackQty = 0
			AND siStatus='closed'
		</cfquery>
		<cfquery name="QFixStockItems3" datasource="#application.site.datasource1#">
			UPDATE tblStockItem
			SET siQtyItems = siPackQty * siQtyPacks
			WHERE siStatus='closed'
		</cfquery>
	</cfif>
	<cfquery name="QStockItems" datasource="#application.site.datasource1#">
		SELECT *
		FROM tblStockItem
		INNER JOIN tblproducts ON prodID=siProduct
		WHERE siStatus='closed'
	</cfquery>
	<cfoutput>
		<table>
			<tr>
				<td>Product</td>
				<td>siID</td>
				<td>siOrder</td>
				<td>siProduct</td>
				<td>siUnitSize</td>
				<td>siPackQty</td>
				<td>siQtyPacks</td>
				<td>siQtyItems</td>
				<td>siUnitTrade</td>
				<td>siOurPrice</td>
			</tr>
			<cfloop query="QStockItems">
				<tr>
					<td>#prodTitle#</td>
					<td>#siID#</td>
					<td>#siOrder#</td>
					<td>#siProduct#</td>
					<td>#siUnitSize#</td>
					<td align="center">#siPackQty#</td>
					<td align="center">#siQtyPacks#</td>
					<td align="center">#siQtyItems#</td>
					<td align="right">#siUnitTrade#</td>
					<td align="right">#siOurPrice#</td>
				</tr>
			</cfloop>
		</table>
	</cfoutput>
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>

</body>
</html>