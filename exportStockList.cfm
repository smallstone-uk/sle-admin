<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<link href="css/main3.css" rel="stylesheet" type="text/css">
	<title>Export StockList</title>
</head>

<cfset parm = {}>
<cfset parm.outFile = "#application.site.dir_data#stock\stocklist.txt">
<cfset parm.datasource = application.site.datasource1>
<cfset parm.dayNo = DayofWeek(Now())>
<cfif parm.dayNo gt 1 AND parm.dayNo lt 5>
	<cfset parm.nextDel = 'Thursday'>
<cfelse>
	<cfset parm.nextDel = 'Monday'>
</cfif>

<cfquery name="getStockListFromDB" datasource="#parm.datasource#">
	SELECT ctlStockList
	FROM tblControl
	WHERE ctlID = 1
</cfquery>
<cfset parm.stocklist = getStockListFromDB.ctlStockList>

<cfquery name="QBarcodes" datasource="#parm.datasource#">
			SELECT prodID,prodStaffDiscount,prodRef,prodRecordTitle,prodTitle,prodCountDate,prodStockLevel,prodLastBought,prodStaffDiscount
					prodPackPrice,prodOurPrice,prodValidTo,prodPriceMarked,prodCatID,prodVATRate,prodReorder,
					siID,siRef,siOrder,siUnitSize,siPackQty,siQtyPacks,siQtyItems,siWSP,siUnitTrade,siRRP,siOurPrice,siPOR,siReceived,siBookedIn,siExpires,siStatus,
					barcode,soDate
			FROM tblProducts
			LEFT JOIN tblStockItem ON prodID = siProduct
			INNER JOIN tblStockOrder ON soID = siOrder
			AND tblStockItem.siID = (
				SELECT MAX( siID )
				FROM tblStockItem
				WHERE prodID = siProduct
				AND siStatus NOT IN ("returned","inactive")  )
			LEFT JOIN tblBarcodes ON prodID = barProdID
			AND tblBarcodes.barID = (
				SELECT MAX(barID)
				FROM tblBarcodes
				WHERE prodID = barProdID )
			WHERE prodID IN (#parm.stockList#)
			ORDER BY prodCatID, prodTitle
</cfquery>
<cfif FileExists(parm.outFile)>
	<cffile action="delete" file="#parm.outFile#">
</cfif>
<cfif QBarcodes.recordcount gt 0>
	<cfoutput>
		<table width="700" class="tableList" border="1">
			<tr>
				<th>Barcode</th>
				<th>Product Ref</th>
				<th>Product Title</th>
				<th>Size</th>
				<th>Qty</th>
				<th>Cases</th>
			</tr>
		<cfloop query="QBarcodes">
			<cffile action="append" file="#parm.outFile#" addnewline="yes"
				output="'#barcode#','#prodRef#','#prodTitle#','#siUnitSize#',#siWSP#,#siRRP#,#siQtyItems#,#siQtyPacks#">
			<tr>
				<td>#barcode#</td>
				<td><a href="productStock6.cfm?product=#prodID#" target="_blank">#prodRef#</a></td>
				<td>#prodTitle#</td>
				<td>#siUnitSize#</td>
				<td align="center">#siQtyItems#</td>
				<td align="center">#siQtyPacks#</td>
			</tr>
		</cfloop>
		</table>
	</cfoutput>
<cfelse>
	No records found to export.
</cfif>
<body>
</body>
</html>