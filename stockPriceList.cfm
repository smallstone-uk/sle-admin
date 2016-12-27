<!DOCTYPE html>
<html>
<head>
<title>Product List</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
<link href="css/productstock.css" rel="stylesheet" type="text/css">
<link href="css/chosen.css" rel="stylesheet" type="text/css">
<link href="css/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" type="text/css">
<script src="common/scripts/common.js"></script>
<script src="scripts/jquery-1.9.1.js"></script>
<script src="scripts/jquery-ui.js"></script>
<script src="scripts/jquery.dcmegamenu.1.3.3.js"></script>
<script src="scripts/jquery.hoverIntent.minified.js"></script>
<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
<script src="scripts/autoCenter.js" type="text/javascript"></script>
<script src="scripts/popup.js" type="text/javascript"></script>
<script src="scripts/jquery.PrintArea.js" type="text/javascript"></script>
<script src="scripts/jquery-barcode.js" type="text/javascript"></script>
<script src="scripts/productStock.js" type="text/javascript"></script>

<body>

<!--- All products with most recent stock item record --->
<!---
	<cfquery name="QStockItems" datasource="#application.site.datasource1#">
		SELECT p.prodID, p.prodTitle, s.siID, s.siProduct, s.siOurPrice
		FROM tblStockItem s
		INNER JOIN tblProducts p ON s.siProduct=p.prodID
		WHERE EXISTS (SELECT * FROM 
		(SELECT MAX(siID) maxID, siProduct pID FROM tblStockItem GROUP BY siProduct) G
		WHERE G.maxID=s.siID AND g.pID=p.prodID)
	</cfquery>
	<cfdump var="#QStockItems#" label="QStockItems" expand="no">
--->
	<cfflush interval="300">
	<cfquery name="QProducts" datasource="#application.site.datasource1#">
		SELECT prodID,prodCatID,prodRef,prodTitle,prodOurPrice,prodPackQty,prodPriceMarked,prodUnitSize,prodValidTo, tblProductCats.pCatTitle
		FROM tblProducts,tblProductCats
		WHERE pcatID=prodCatID
		AND prodPriceMarked=0
		ORDER BY pCatTitle ASC, prodTitle ASC
	</cfquery>
	<cfoutput>
		<p>#QProducts.recordcount# products</p>
		<table width="700" class="tableList" border="1">
			<tr>
				<th>Reference</th>
				<th>Title</th>
				<th>Unit Size</th>
				<th>Our Price</th>
				<th>Pack Qty</th>
				<th>Valid To</th>
			</tr>
		<cfset category=0>
		<cfloop query="QProducts">
			<cfif prodCatID neq category>
				<tr>
					<td colspan="6" style="background-color:##eeeeee"><strong>#pCatTitle#</strong></td>
				</tr>
				<cfset category=prodCatID>
			</cfif>
			<tr>
				<td>#prodRef#</td>
				<td>#prodTitle#</td>
				<td>#prodUnitSize#</td>
				<td>&pound;#prodOurPrice# #GetToken(" ,PM",prodPriceMarked+1,",")#</td>
				<td>#prodPackQty#</td>
				<td>#LSDateFormat(prodValidTo,"ddd dd-mmm")#</td>
			</tr>
		</cfloop>
		</table>
	</cfoutput>
	<!---<cfdump var="#QProducts#" label="QProducts" expand="no">--->
