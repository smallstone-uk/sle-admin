<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Sales Pivot Table</title>
<link rel="stylesheet" type="text/css" href="css/main3.css"/>
</head>

<cfparam name="theYear" default="#Year(now())#">
<cfparam name="group" default="0">
<cfparam name="category" default="0">
<cfobject component="code/sales" name="sales">
<cfset parms={}>
<cfset parms.datasource=application.site.datasource1>
<cfset parms.grpID=group>
<cfset parms.catID=category>
<cfset parms.rptYear=theYear>
<cfset QSales = sales.pivotTable(parms)>
<!---<cfdump var="#QSales#" label="QSales" expand="false">--->
<body>
<cfoutput>
	<table class="tableList" border="1">
		<tr>
			<th>Category</th>
			<th>Product</th>
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
		</tr>
	<cfloop query="QSales.salesItems">
		<tr>
			<td>#pcatTitle#</td>
			<td>#prodTitle#</td>
			<td width="30" align="right"><cfif jan gt 0>#jan#</cfif></td>
			<td width="30" align="right"><cfif feb gt 0>#feb#</cfif></td>
			<td width="30" align="right"><cfif mar gt 0>#mar#</cfif></td>
			<td width="30" align="right"><cfif apr gt 0>#apr#</cfif></td>
			<td width="30" align="right"><cfif may gt 0>#may#</cfif></td>
			<td width="30" align="right"><cfif jun gt 0>#jun#</cfif></td>
			<td width="30" align="right"><cfif jul gt 0>#jul#</cfif></td>
			<td width="30" align="right"><cfif aug gt 0>#aug#</cfif></td>
			<td width="30" align="right"><cfif sep gt 0>#sep#</cfif></td>
			<td width="30" align="right"><cfif oct gt 0>#oct#</cfif></td>
			<td width="30" align="right"><cfif nov gt 0>#nov#</cfif></td>
			<td width="30" align="right"><cfif dec gt 0>#dec#</cfif></td>
			<td width="50" align="right">#total#</td>
		</tr>
	</cfloop>
	</table>
</cfoutput>
</body>
</html>
