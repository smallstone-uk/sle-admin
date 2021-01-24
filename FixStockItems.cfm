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
	<cfquery name="QStockItems1" datasource="#application.site.datasource1#">
		SELECT tblStockItem.*, prodTitle, 'siPackQty is zero 1st pass' AS err
		FROM tblStockItem
		INNER JOIN tblProducts ON prodID=siProduct
		WHERE siPackQty = 0
		AND siQtyItems > 0
		AND siQtyPacks > 0
	</cfquery>
	<cfif doUpdate>
		<!--- Fix packQty if zero, only if items and qtypack gt zero  --->
		<cfquery name="QFixStockItems1" datasource="#application.site.datasource1#">
			UPDATE tblStockItem
			SET siPackQty = siQtyItems / siQtyPacks
			WHERE siPackQty = 0
			AND siQtyItems > 0
			AND siQtyPacks > 0
		</cfquery>
	</cfif>
	<cfquery name="QStockItems2" datasource="#application.site.datasource1#">
		SELECT tblStockItem.*, prodTitle, 'siPackQty is zero 2nd pass' AS err
		FROM tblStockItem
		INNER JOIN tblProducts ON prodID=siProduct
		WHERE siPackQty = 0
		AND siStatus='closed'
	</cfquery>
	<cfif doUpdate>
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
	</cfif>
	<cfquery name="QStockItems3" datasource="#application.site.datasource1#">
		SELECT tblStockItem.*, prodTitle, 'siQtyItems is incorrect' AS err
		FROM tblStockItem
		INNER JOIN tblProducts ON prodID=siProduct
		WHERE siQtyItems != siPackQty * siQtyPacks
		AND siStatus='closed'		
	</cfquery>
	<cfif doUpdate>
		<!--- Correct qtyItem calculation --->
		<cfquery name="QFixStockItems3" datasource="#application.site.datasource1#">
			UPDATE tblStockItem
			SET siQtyItems = siPackQty * siQtyPacks
			WHERE siQtyItems != siPackQty * siQtyPacks
			AND siStatus='closed'		
		</cfquery>
	</cfif>
	<cfquery name="QStockItems4" datasource="#application.site.datasource1#">
		SELECT tblStockItem.*, prodTitle, 'siQtyItems not zero if out of stock' AS err
		FROM tblStockItem
		INNER JOIN tblProducts ON prodID=siProduct
		WHERE siStatus='outofstock'
		AND siQtyItems != 0
	</cfquery>
	<cfif doUpdate>
		<!--- Clear qtyItem if item out of stock --->
		<cfquery name="QFixStockItems4" datasource="#application.site.datasource1#">
			UPDATE tblStockItem
			SET siQtyItems = 0
			WHERE siStatus='outofstock'
			AND siQtyItems != 0
		</cfquery>
	</cfif>
	<cfquery name="QStockItems" dbtype="query">
		SELECT * FROM QStockItems1
		UNION
		SELECT * FROM QStockItems2
		UNION
		SELECT * FROM QStockItems3
		UNION
		SELECT * FROM QStockItems4
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
				<td>siStatus</td>
				<td>error</td>
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
					<td align="right">#siStatus#</td>
					<td align="right">#err#</td>
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