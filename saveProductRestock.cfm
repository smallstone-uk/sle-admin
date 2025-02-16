<cftry>
<cfsetting showdebugoutput="no">
<cfobject component="code/stock" name="stock">
<cfset parm = {}>
<cfset parm.newStockLevel = stockQty>
<cfset parm.product = prodID>
<cfset parm.datasource = application.site.datasource1>
<cfset saveStockLevel = stock.SaveProductRestock(parm)>

<cfoutput>#parm.newStockLevel#</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="no">
</cfcatch>
</cftry>