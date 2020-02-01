<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Stock Movement</title>
</head>

<cfset loc = {}>
<cfset loc.searchFrom = '2019-08-01'>
<cfset loc.searchTo = '2019-12-31'>
<cfset loc.products = '69282,16811,99242,100452'>

<cfquery name="loc.QSalesBFwd" datasource="#application.site.datasource1#">
	SELECT eiProdID, SUM(eiQty ) AS Qty, SUM(eiNet) AS Net
	FROM tblepos_items
	WHERE eiProdID IN (#loc.products#)
	AND DATE(eiTimestamp) < '#loc.searchFrom#'
	GROUP BY eiProdID
</cfquery>
<cfset loc.SalesBFWDs = {}>
<cfif loc.QSalesBFwd.recordcount gt 0>
	<cfloop query="loc.QSalesBFwd">
		<cfset StructInsert(loc.SalesBFWDs,eiProdID,{"Qty" = Qty,"Net" = Net})>
	</cfloop>
</cfif>

<cfquery name="loc.QSales" datasource="#application.site.datasource1#">
	SELECT prodID,prodTitle, tblepos_items.*  
	FROM tblepos_items
	INNER JOIN tblProducts ON eiProdID=prodID
	WHERE eiProdID IN (#loc.products#)
	AND DATE(eiTimestamp) BETWEEN '#loc.searchFrom#' AND '#loc.searchTo#'
</cfquery>

<cfquery name="loc.QPurchBFwd" datasource="#application.site.datasource1#">
	SELECT siProduct, SUM(siQtyItems ) AS Qty, SUM(siWSP) AS WSP
	FROM tblstockitem
	WHERE siProduct IN (#loc.products#)
	AND DATE(siBookedIn) < '#loc.searchFrom#'
	GROUP BY siProduct
</cfquery>
<cfquery name="loc.QPurch" datasource="#application.site.datasource1#">
	SELECT prodID,prodTitle, tblstockitem.*  
	FROM tblstockitem
	INNER JOIN tblProducts ON siProduct=prodID
	WHERE siProduct IN (#loc.products#)
	AND DATE(siBookedIn) BETWEEN '#loc.searchFrom#' AND '#loc.searchTo#'
</cfquery>

<body>
	<cfdump var="#loc#" label="loc" expand="false">
</body>
</html>