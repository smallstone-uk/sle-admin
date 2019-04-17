<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Stock Sales &amp; Purchase</title>
<link rel="stylesheet" type="text/css" href="css/main3.css"/>
<style>
	.sale {color:#FF00FF;}
	.purch {color:#0000FF}
	.group {font-size:24px; font-weight:bold}
</style>
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
<!---<cfdump var="#QSales#" label="QSales" expand="false">--->
<cfset Purch = sales.stockPurchByMonth(parms)>
<!---<cfdump var="#Purch#" label="Purch" expand="false">--->
<body>
<cfoutput>
	<table class="tableList" border="1">
		<tr>
			<th>Stock Report</th>
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
			<th width="50" align="right">Total</th>
			<th width="50" align="right">Stock</th>
		</tr>
	<cfset categoryID = 0>
	<cfset groupID = 0>
	<cfloop query="QSales.salesItems">
		<cfif groupID neq pgID>
			<tr>
				<th colspan="15"><span class="group">#pgTitle#</span></th>
			</tr>
			<cfset groupID = pgID>
		</cfif>
		<cfif categoryID neq pcatID>
			<tr>
				<th colspan="15">#pcatTitle#</th>
			</tr>
			<cfset categoryID = pcatID>
		</cfif>
		<cfset purRec = {}>
		<cfif StructKeyExists(Purch.stock,prodID)>
			<cfset purRec = StructFind(Purch.stock,prodID)>
		</cfif>
		<tr>
			<td>#prodTitle#</td>
			<td width="30" align="right">
				<cfif jan gt 0><span class="sale"><span class="sale">#jan#<br /></span></cfif>
				<cfif !StructIsEmpty(purRec) AND purRec.jan gt 0><span class="purch">#purRec.jan#</span></cfif>
			</td>
			<td width="30" align="right">
				<cfif feb gt 0><span class="sale">#feb#<br /></span></cfif>
				<cfif !StructIsEmpty(purRec) AND purRec.feb gt 0><span class="purch">#purRec.feb#</span></cfif>
			</td>
			<td width="30" align="right">
				<cfif mar gt 0><span class="sale">#mar#<br /></span></cfif>
				<cfif !StructIsEmpty(purRec) AND purRec.mar gt 0><span class="purch">#purRec.mar#</span></cfif>
			</td>
			<td width="30" align="right">
				<cfif apr gt 0><span class="sale">#apr#<br /></span></cfif>
				<cfif !StructIsEmpty(purRec) AND purRec.apr gt 0><span class="purch">#purRec.apr#</span></cfif>
			</td>
			<td width="30" align="right">
				<cfif may gt 0><span class="sale">#may#<br /></span></cfif>
				<cfif !StructIsEmpty(purRec) AND purRec.may gt 0><span class="purch">#purRec.may#</span></cfif>
			</td>
			<td width="30" align="right">
				<cfif jun gt 0><span class="sale">#jun#<br /></span></cfif>
				<cfif !StructIsEmpty(purRec) AND purRec.jun gt 0><span class="purch">#purRec.jun#</span></cfif>
			</td>
			<td width="30" align="right">
				<cfif jul gt 0><span class="sale">#jul#<br /></span></cfif>
				<cfif !StructIsEmpty(purRec) AND purRec.jul gt 0><span class="purch">#purRec.jul#</span></cfif>
			</td>
			<td width="30" align="right">
				<cfif aug gt 0><span class="sale">#aug#<br /></span></cfif>
				<cfif !StructIsEmpty(purRec) AND purRec.aug gt 0><span class="purch">#purRec.aug#</span></cfif>
			</td>
			<td width="30" align="right">
				<cfif sep gt 0><span class="sale">#sep#<br /></span></cfif>
				<cfif !StructIsEmpty(purRec) AND purRec.sep gt 0><span class="purch">#purRec.sep#</span></cfif>
			</td>
			<td width="30" align="right">
				<cfif oct gt 0><span class="sale">#oct#<br /></span></cfif>
				<cfif !StructIsEmpty(purRec) AND purRec.oct gt 0><span class="purch">#purRec.oct#</span></cfif>
			</td>
			<td width="30" align="right">
				<cfif nov gt 0><span class="sale">#nov#<br /></span></cfif>
				<cfif !StructIsEmpty(purRec) AND purRec.nov gt 0><span class="purch">#purRec.nov#</span></cfif>
			</td>
			<td width="30" align="right">
				<cfif dec gt 0><span class="sale">#dec#<br /></span></cfif>
				<cfif !StructIsEmpty(purRec) AND purRec.dec gt 0><span class="purch">#purRec.dec#</span></cfif>
			</td>
			<td width="50" align="right">
				<span class="sale">#total#<br /></span>
				<cfif !StructIsEmpty(purRec)><span class="purch">#purRec.total#</span></cfif>
			</td>
			<td width="50" align="right">
				<cfif !StructIsEmpty(purRec)>#purRec.total - total#</cfif>
			</td>
		</tr>
	</cfloop>
	</table>
</cfoutput>
</body>
</html>
