<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<link href="css/main3.css" rel="stylesheet" type="text/css">
	<title>Export StockList</title>
</head>

<body>
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

<cfquery name="QProdStock" datasource="#parm.datasource#">
	SELECT 	pcatTitle,prodID,prodStaffDiscount,prodRef,prodRecordTitle,prodTitle,prodCountDate,prodStockLevel,prodLastBought,prodStaffDiscount
			prodPackPrice,prodOurPrice,prodValidTo,prodPriceMarked,prodCatID,prodVATRate,prodReorder,
			siID,siRef,siOrder,siUnitSize,siPackQty,siQtyPacks,siQtyItems,siWSP,siUnitTrade,siRRP,siOurPrice,siPOR,siReceived,siBookedIn,siExpires,siStatus,
			barcode,soDate
	FROM tblProducts
	LEFT JOIN tblStockItem ON prodID = siProduct
	INNER JOIN tblStockOrder ON soID = siOrder
	INNER JOIN tblProductCats ON pcatID = prodCatID
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
	ORDER BY pcatTitle, prodTitle
</cfquery>

<cftry>
	<cfif FileExists(parm.outFile)>
		<cffile action="delete" file="#parm.outFile#">
	</cfif>
	<cffile action="append" file="#parm.outFile#" addnewline="yes"
		output="ID,Barcode,Reference,Category,Product,UnitSize,WSP,RRP,PackQty,Cases">
<cfcatch type="any">
	<cfoutput><h1>File: #parm.outFile# is currently in use. Please close it first.</h1></cfoutput>
	<cfabort>
</cfcatch>
</cftry>

<cfif QProdStock.recordcount gt 0>
	<cfoutput>
		<table width="900" class="tableList" border="1">
			<tr>
				<th>Barcode</th>
				<th>Product Ref</th>
				<th>Category</th>
				<th>Product Title</th>
				<th>Size</th>
				<th>RRP</th>
				<th>WSP</th>
				<th>Qty</th>
				<th>Cases</th>
			</tr>
		<cfloop query="QProdStock">
			<cffile action="append" file="#parm.outFile#" addnewline="yes"
				output="'#prodID#,#barcode#','#prodRef#','#pcatTitle#','#prodTitle#','#siUnitSize#',#siWSP#,#siRRP#,#siPackQty#,#siQtyPacks#">
			<tr>
				<td>#prodID#</td>
				<td>#barcode#</td>
				<td><a href="productStock6.cfm?product=#prodID#" target="_blank">#prodRef#</a></td>
				<td>#pcatTitle#</td>
				<td>#prodTitle#</td>
				<td>#siUnitSize#</td>
				<td>#siRRP#</td>
				<td>#siWSP#</td>
				<td align="center">#siPackQty#</td>
				<td align="center">#siQtyPacks#</td>
			</tr>
		</cfloop>
		</table>
	</cfoutput>
<cfelse>
	No records found to export.
</cfif>
</body>
</html>