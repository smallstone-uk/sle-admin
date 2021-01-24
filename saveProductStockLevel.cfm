<cftry>
<cfsetting showdebugoutput="no">
<cfobject component="code/stock" name="stock">
<cfset parm = {}>
<cfset parm.stockLevel = stockLevel>
<cfset parm.product = prodID>
<cfset parm.datasource = application.site.datasource1>
<cfset saveStock = stock.SaveProductStock(parm)>

<cfoutput>#parm.stockLevel#</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="no">
</cfcatch>
</cftry>